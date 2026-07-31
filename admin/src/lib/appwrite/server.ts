import { Client, Account, Databases, Query } from "node-appwrite";
import { getAppwriteConfig } from "./config";

export function createAdminClient() {
  const { endpoint, projectId } = getAppwriteConfig();
  const apiKey = process.env.APPWRITE_API_KEY;

  if (!apiKey) {
    throw new Error("APPWRITE_API_KEY is not configured.");
  }

  return new Client().setEndpoint(endpoint).setProject(projectId).setKey(apiKey);
}

export function createSessionClient(sessionSecret: string) {
  const { endpoint, projectId } = getAppwriteConfig();

  return new Client()
    .setEndpoint(endpoint)
    .setProject(projectId)
    .setSession(sessionSecret);
}

export async function getAccountForSession(sessionSecret: string) {
  const client = createSessionClient(sessionSecret);
  const account = new Account(client);
  return account.get();
}

export async function listDocumentTotal(
  collectionId: string,
  queries: string[] = [Query.limit(1)],
) {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const result = await databases.listDocuments(databaseId, collectionId, queries);
  return result.total;
}
