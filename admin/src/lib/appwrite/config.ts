const endpoint = process.env.APPWRITE_ENDPOINT ?? "https://api.tcidpodcast.com/v1";
const projectId = process.env.APPWRITE_PROJECT_ID ?? "tcidpodcast";
const databaseId = process.env.APPWRITE_DATABASE_ID ?? "episodes";

export function getAppwriteConfig() {
  return { endpoint, projectId, databaseId };
}

export function sessionCookieName() {
  return `a_session_${projectId}`;
}
