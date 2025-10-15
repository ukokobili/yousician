## What type of PR is this? (check all applicable)
- [ ] 🍕 Created New Model
- [ ] 🎨 Enhanced Query
- [ ] 🐛 Bug Fix

Title: `Built Ad Network Mdoel`

### Description
This PR implements a new dbt model for dbt documentation. It includes the following changes:

- New dbt model: `models/mart/fct__ae_ad_network_geo_performance` `models/descriptions/__overview__.md`
- Updates to `*.yml` to include the test
- New unit tests has been added to the model
- Documentation updates in `models/descriptions/__overview__.md`

### Key Changes
1. Added CI/CD workflow and PR template.
2. SQLfluff added to `Makefile`

### Dependencies
- No dependencies at the moment

### Testing
- Verified results against manual calculations for a sample period

### Documentation
- Updated `models/descriptions/__overview__.md` with details on the calculation methodology

### Deployment Notes
This change will be included in the next nightly dbt run. Please monitor the MoreDemand dashboard for any unexpected changes.

---

## Checklist for Reviewers
- [ ] 👍 SQL logic is correct and efficient
- [ ] 🙅‍♂️ Unit tests cover edge cases
- [ ] 📜 Documentation is clear and complete
- [ ] 🎨 Changes align with our data modeling standards

- [ ] 📊 No unintended impacts on existing models or dashboards