// RSS Sync Edge Function
// Validates HTTPS feed URL, parses episodes, deduplicates by GUID, preserves manual edits

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface RSSItem {
  guid: string;
  title: string;
  description: string;
  audioUrl: string;
  coverArtUrl: string | null;
  durationSeconds: number | null;
  publishedAt: string | null;
  seasonNumber: number | null;
  episodeNumber: number | null;
  isExplicit: boolean;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function parseDuration(value: string | null | undefined): number | null {
  if (!value) return null;
  const trimmed = value.trim();
  if (/^\d+$/.test(trimmed)) return parseInt(trimmed, 10);
  const parts = trimmed.split(":").map(Number);
  if (parts.some(Number.isNaN)) return null;
  if (parts.length === 3) return parts[0] * 3600 + parts[1] * 60 + parts[2];
  if (parts.length === 2) return parts[0] * 60 + parts[1];
  return null;
}

function extractTag(xml: string, tag: string): string {
  const cdata = new RegExp(`<${tag}[^>]*><!\\[CDATA\\[([\\s\\S]*?)\\]\\]></${tag}>`, "i");
  const plain = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)</${tag}>`, "i");
  const match = xml.match(cdata) ?? xml.match(plain);
  return match?.[1]?.trim() ?? "";
}

function stripHtml(html: string): string {
  return html
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/\s+/g, " ")
    .trim();
}

function extractAttribute(xml: string, tag: string, attribute: string): string {
  const pattern = new RegExp(`<${tag}[^>]*${attribute}=["']([^"']+)["']`, "i");
  return xml.match(pattern)?.[1]?.trim() ?? "";
}

function parseRSSFeed(xml: string): { title: string; artwork: string; items: RSSItem[] } {
  const channelMatch = xml.match(/<channel>([\s\S]*?)<\/channel>/i);
  const channel = channelMatch?.[1] ?? xml;
  const title = stripHtml(extractTag(channel, "title"));
  const artwork =
    extractAttribute(channel, "itunes:image", "href") ||
    channel.match(/<image>\s*<url>([^<]+)<\/url>/i)?.[1]?.trim() ||
    "";

  const itemMatches = [...channel.matchAll(/<item>([\s\S]*?)<\/item>/gi)];
  const items: RSSItem[] = itemMatches.map((m) => {
    const item = m[1];
    const guid = extractTag(item, "guid") || extractTag(item, "link");
    const enclosure = item.match(/<enclosure[^>]+url="([^"]+)"/i)?.[1] ?? "";
    const itunesExplicit = extractTag(item, "itunes:explicit").toLowerCase();
    const rawDescription = extractTag(item, "description") || extractTag(item, "itunes:summary");
    const seasonRaw = extractTag(item, "itunes:season") || extractTag(item, "podcast:season");
    const episodeRaw = extractTag(item, "itunes:episode") || extractTag(item, "podcast:episode");

    return {
      guid,
      title: stripHtml(extractTag(item, "title") || extractTag(item, "itunes:title")),
      description: stripHtml(rawDescription),
      audioUrl: enclosure,
      coverArtUrl: extractAttribute(item, "itunes:image", "href") || null,
      durationSeconds: parseDuration(extractTag(item, "itunes:duration")),
      publishedAt: extractTag(item, "pubDate") || null,
      seasonNumber: parseInt(seasonRaw, 10) || null,
      episodeNumber: parseInt(episodeRaw, 10) || null,
      isExplicit: itunesExplicit === "yes" || itunesExplicit === "true",
    };
  });

  return { title, artwork, items };
}

function validateFeedUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return parsed.protocol === "https:";
  } catch {
    return false;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceKey);

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json().catch(() => ({}));
    const sourceId = body.source_id as string | undefined;
    const manualRefresh = body.manual === true;

    let query = supabase.from("rss_sources").select("*").eq("is_active", true);
    if (sourceId) query = query.eq("id", sourceId);

    const { data: sources, error: sourcesError } = await query;
    if (sourcesError) throw sourcesError;
    if (!sources?.length) {
      return new Response(JSON.stringify({ message: "No active RSS sources" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const results = [];

    for (const source of sources) {
      const logStart = new Date().toISOString();
      let imported = 0;
      let updated = 0;
      let skipped = 0;
      let errorMessage: string | null = null;
      let status: "success" | "partial" | "failed" = "success";

      try {
        if (!validateFeedUrl(source.feed_url)) {
          throw new Error("Invalid feed URL: HTTPS required");
        }

        const response = await fetch(source.feed_url, {
          headers: { "User-Agent": "TCIDPodcastRSSSync/1.0" },
        });
        if (!response.ok) throw new Error(`Feed fetch failed: ${response.status}`);

        const xml = await response.text();
        const parsed = parseRSSFeed(xml);

        await supabase
          .from("rss_sources")
          .update({
            podcast_title: parsed.title || source.podcast_title,
            podcast_artwork_url: parsed.artwork || source.podcast_artwork_url,
          })
          .eq("id", source.id);

        for (const item of parsed.items) {
          if (!item.guid || !item.title || !item.audioUrl) {
            skipped++;
            continue;
          }

          const { data: existing } = await supabase
            .from("episodes")
            .select("id, manually_edited_fields")
            .eq("rss_guid", item.guid)
            .maybeSingle();

          const preserved = existing?.manually_edited_fields ?? [];
          const payload: Record<string, unknown> = {
            rss_guid: item.guid,
            source: "rss",
            status: "published",
            title: preserved.includes("title") ? undefined : item.title,
            description: preserved.includes("description") ? undefined : item.description,
            audio_url: preserved.includes("audio_url") ? undefined : item.audioUrl,
            cover_art_url: preserved.includes("cover_art_url") ? undefined : item.coverArtUrl,
            duration_seconds: preserved.includes("duration_seconds") ? undefined : item.durationSeconds,
            season_number: preserved.includes("season_number") ? undefined : item.seasonNumber,
            episode_number: preserved.includes("episode_number") ? undefined : item.episodeNumber,
            is_explicit: preserved.includes("is_explicit") ? undefined : item.isExplicit,
            published_at: preserved.includes("published_at")
              ? undefined
              : item.publishedAt
                ? new Date(item.publishedAt).toISOString()
                : new Date().toISOString(),
          };

          Object.keys(payload).forEach((k) => payload[k] === undefined && delete payload[k]);

          if (existing) {
            if (Object.keys(payload).length > 2) {
              await supabase.from("episodes").update(payload).eq("id", existing.id);
              updated++;
            } else {
              skipped++;
            }
          } else {
            await supabase.from("episodes").insert({
              ...payload,
              title: item.title,
              description: item.description,
              audio_url: item.audioUrl,
              cover_art_url: item.coverArtUrl,
              duration_seconds: item.durationSeconds,
              season_number: item.seasonNumber,
              episode_number: item.episodeNumber,
              is_explicit: item.isExplicit,
              published_at: item.publishedAt
                ? new Date(item.publishedAt).toISOString()
                : new Date().toISOString(),
            });
            imported++;
          }
        }
      } catch (err) {
        status = "failed";
        errorMessage = err instanceof Error ? err.message : "Unknown error";
      }

      await supabase.from("rss_sync_logs").insert({
        rss_source_id: source.id,
        status,
        episodes_imported: imported,
        episodes_updated: updated,
        episodes_skipped: skipped,
        error_message: errorMessage,
        started_at: logStart,
        completed_at: new Date().toISOString(),
        metadata: { manual: manualRefresh },
      });

      await supabase
        .from("rss_sources")
        .update({
          last_synced_at: new Date().toISOString(),
          last_sync_status: status,
          last_error: errorMessage,
        })
        .eq("id", source.id);

      results.push({ source_id: source.id, status, imported, updated, skipped, error: errorMessage });
    }

    return new Response(JSON.stringify({ results }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Internal error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
