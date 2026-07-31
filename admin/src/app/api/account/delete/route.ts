import { Account, Client, Databases, Users } from "node-appwrite";
import { NextResponse } from "next/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";

export async function POST(request: Request) {
  const authHeader = request.headers.get("authorization") ?? "";
  const jwt = authHeader.startsWith("Bearer ") ? authHeader.slice(7).trim() : "";

  if (!jwt) {
    return NextResponse.json({ error: "Missing authorization." }, { status: 401 });
  }

  const { endpoint, projectId, databaseId } = getAppwriteConfig();
  const apiKey = process.env.APPWRITE_API_KEY;

  if (!apiKey) {
    return NextResponse.json({ error: "Server misconfigured." }, { status: 500 });
  }

  try {
    const sessionClient = new Client().setEndpoint(endpoint).setProject(projectId).setJWT(jwt);
    const account = new Account(sessionClient);
    const user = await account.get();

    const adminClient = new Client().setEndpoint(endpoint).setProject(projectId).setKey(apiKey);
    const databases = new Databases(adminClient);
    const users = new Users(adminClient);

    try {
      await databases.deleteDocument(databaseId, "profiles", user.$id);
    } catch {
      // Profile may not exist.
    }

    await users.delete(user.$id);

    return NextResponse.json({ ok: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Could not delete account.";
    return NextResponse.json({ error: message }, { status: 400 });
  }
}
