# Recover SSO

1. Establish whether failure is DNS/TLS, Keycloak availability, database
   availability, realm configuration, or one client's redirect URI.
2. Preserve one working administrator session. Do not restart every Keycloak
   replica or rotate realm keys while diagnosis is incomplete.
3. Check Keycloak events and health, PostgreSQL cluster status, certificate
   validity, proxy headers, issuer URL, and time synchronization.
4. For a bad GitOps change, revert the smallest safe configuration change. For
   data loss, restore PostgreSQL into an isolated recovery environment first.
5. Validate admin login and one non-privileged login for each relying-party
   class. Revoke temporary accounts and record any emergency access used.

Keep an offline, audited break-glass identity whose credentials and procedure
are managed outside this repository.

