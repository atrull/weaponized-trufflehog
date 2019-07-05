# weaponized-trufflehog
A script to weaponize trufflehog scans of (public) repos associated with members of an org you care about (or want to breach).

Why does it exist ?

trufflehog is nice but doesn't do grand-scale stuff (it aims at a specific repo), so we need to wrap it in something to grab more repos.

gitrob is nice but but it doesn't search deeply (sticks to filenames) - it does however scan all public repos associated with some orgs members.

tools that get results might not scan how we want or where we want.
