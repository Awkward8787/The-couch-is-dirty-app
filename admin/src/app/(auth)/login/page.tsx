import Image from "next/image";
import { redirect } from "next/navigation";
import { loginAction } from "@/lib/auth/actions";
import { getSessionUser } from "@/lib/auth/session";
import { TcidButton } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import { TcidInput } from "@/components/ui/tcid-input";
import pageStyles from "@/components/ui/page.module.css";
import styles from "./login.module.css";

const ERROR_MESSAGES: Record<string, string> = {
  missing: "Email and password are required.",
  invalid: "Invalid email or password.",
  "not-allowed": "This account is not authorized for admin access.",
  server: "Could not complete sign in. Check Appwrite connectivity and try again.",
};

type LoginPageProps = {
  searchParams: Promise<{ error?: string }>;
};

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const user = await getSessionUser();
  if (user) redirect("/");

  const params = await searchParams;
  const errorMessage = params.error ? ERROR_MESSAGES[params.error] : undefined;

  return (
    <div className={styles.authPage}>
      <TcidCard className={styles.authCard}>
        <div className={styles.logoWrap}>
          <Image
            src="/podcast-logo.png"
            alt="The Couch Is Dirty Podcast"
            width={180}
            height={46}
            priority
          />
        </div>

        <h1 className={styles.title}>Sign in</h1>
        <p className={styles.subtitle}>
          Creator access for The Couch Is Dirty Podcast. Use{" "}
          <strong>anthony@vibevirtue.com</strong> (lowercase).
        </p>

        {errorMessage ? <p className={pageStyles.error}>{errorMessage}</p> : null}

        <form className={styles.form} action={loginAction}>
          <TcidInput
            label="Email"
            name="email"
            type="email"
            autoComplete="email"
            defaultValue="anthony@vibevirtue.com"
            required
          />
          <TcidInput
            label="Password"
            name="password"
            type="password"
            autoComplete="current-password"
            required
          />
          <TcidButton type="submit" fullWidth>
            Sign in
          </TcidButton>
        </form>
      </TcidCard>
    </div>
  );
}
