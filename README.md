# weaponized-trufflehog
A script to weaponize trufflehog scans of (public) repos associated with members of an org you care about (or want to breach).

Why does it exist ?

Users occasionaly accidentaly make public repos on their own github users which contain private secrets belonging to another org, by accident, of course.

Tools that didn't quite do what was needed:

trufflehog is nice but doesn't do grand-scale stuff (it aims at a specific repo), so we need to wrap it in something to grab more repos.

gitrob is nice but but it doesn't search deeply (sticks to filenames) - it does however scan all public repos associated with some orgs members.

git secrets is nice but really aimed at git process hooks, which are unenforcable at an org level.

gitleaks looks nice but may not be as weaponized as desired (public repos of org members).
