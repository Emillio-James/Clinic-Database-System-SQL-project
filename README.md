# Clinic database with row-level security

A clinic database on Supabase where **the database itself decides who can see what**. Patients sign in and see only their own appointments and treatments. Doctors see and manage everything. Anyone else sees no medical data at all.

**Tools:** PostgreSQL, Supabase, Supabase Auth, row-level security (RLS)
**Portfolio:** [emillio-james.github.io](https://emillio-james.github.io)

## Why row-level security

Most apps filter data in their own code, so one forgotten filter can show a patient someone else's records. With row-level security the rule lives in the database. Every query is filtered for the signed-in user automatically, whichever app or tool sends it.

## What's in this repository

| File | What it contains |
|---|---|
| [`schema.sql`](schema.sql) | Tables, sample data, links to Supabase Auth users, and the security policies |
| [`tests.sql`](tests.sql) | Five security tests with the expected result above each query, plus checks |
| [`SECURITY_NOTES.md`](SECURITY_NOTES.md) | How the roles and policies work, and what a real deployment would still need |

## How access works

Each patient and doctor row has an `auth_id` that links it to a Supabase Auth account. The policies compare it with `auth.uid()`, the ID of whoever is signed in.

| Signed in as | Patients | Doctors | Appointments | Treatments |
|---|---|---|---|---|
| Patient | Own profile only | All (to book) | Own, read-only | Own, read-only |
| Doctor | All | All | All, can edit | All, can edit |
| Signed in, not registered | None | All | None | None |

A role column isn't needed: someone is a doctor because their auth ID is in the Doctors table.

## Test results

I ran [`tests.sql`](tests.sql) against the schema and every test gave the expected result:

| Test | Expected | Result |
|---|---|---|
| Patient John Kamau views records | Only his 1 appointment and 1 treatment | ✅ |
| Patient edits an appointment | Blocked (`UPDATE 0`) | ✅ |
| Patient Jane Wanjiku views records | Only her own, none of John's | ✅ |
| Doctor views records | All 10 patients, 10 appointments, 8 treatments | ✅ |
| Doctor updates an appointment and adds a treatment | Both succeed | ✅ |
| Unregistered user views records | Nothing | ✅ |

A blocked update in RLS doesn't raise an error. The row is simply invisible to that user, so the update changes nothing, and the tests check for exactly that.

## How to run it

1. Create a project at [supabase.com](https://supabase.com).
2. Create test users under **Authentication → Users**, then swap their IDs into the `UPDATE … SET auth_id` lines in `schema.sql`.
3. Run [`schema.sql`](schema.sql) in the **SQL Editor**, then [`tests.sql`](tests.sql).

All names and phone numbers are fictional.

## Ideas for next steps

- Limit each doctor to their own patients instead of everyone's.
- Add an audit table that records who viewed or changed each record.
- Add a billing table. The reporting side of a hospital database is in my [Hospital SQL project](https://github.com/Emillio-James/Hospital-SQL-Project).

---

**James Mwai** · Data Analyst, Nairobi · [Portfolio](https://emillio-james.github.io) · emmjayjames@gmail.com
