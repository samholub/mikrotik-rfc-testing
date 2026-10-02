# Contributing

Field results, bench results, corrections and script improvements are all welcome.

## Before you post anything

Remove what identifies your network: passwords, public and private addresses,
customer and site names, circuit IDs, router serial numbers and identities.
A RouterOS `/export hide-sensitive` does **not** remove passwords inside scripts.

## Sharing a result

Open an issue with the "Field or bench result" template. Include the router
models and RouterOS versions at both ends, the script version (commit), the
mode and speed, and the full result block and summary as printed.

## Changing the script

The rule this project follows: a change to how the test measures or judges
lands with a bench or field record that shows why. Open a pull request with the
change and the record (under `results/`), and describe what the record shows.
Keep the script under 29,000 bytes: RouterOS truncates longer script sources.

## Scope

RouterOS 7, MikroTik's `/tool/bandwidth-test`, and Layer 2 / Layer 3 forwarding
capability. The project is not affiliated with MikroTik.
