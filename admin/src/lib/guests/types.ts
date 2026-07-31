export const GUEST_APPLICATION_STATUSES = ["pending", "approved", "declined"] as const;

export type GuestApplicationStatus = (typeof GUEST_APPLICATION_STATUSES)[number];

export type AdminGuestApplication = {
  id: string;
  name: string;
  email: string | null;
  topic: string | null;
  message: string | null;
  format: string | null;
  status: GuestApplicationStatus;
  createdAt: string;
};

export type GuestListFilter = {
  status?: GuestApplicationStatus | "all";
};
