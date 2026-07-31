import { getAppwriteConfig } from "./config";

export function postImageViewUrl(fileId: string): string {
  const { endpoint, projectId } = getAppwriteConfig();
  return `${endpoint}/storage/buckets/post-images/files/${fileId}/view?project=${projectId}`;
}

export function avatarViewUrl(fileId: string): string {
  const { endpoint, projectId } = getAppwriteConfig();
  return `${endpoint}/storage/buckets/avatars/files/${fileId}/view?project=${projectId}`;
}
