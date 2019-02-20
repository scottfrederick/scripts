cf create-user sfrederick@pivotal.io springme
cf create-org sfrederick-org -q runaway
cf create-space development -o sfrederick-org 
cf set-org-role sfrederick@pivotal.io sfrederick-org OrgManager
cf set-org-role sfrederick@pivotal.io sfrederick-org BillingManager
cf set-org-role sfrederick@pivotal.io sfrederick-org OrgAuditor
cf set-space-role sfrederick@pivotal.io sfrederick-org development SpaceDeveloper
cf set-space-role sfrederick@pivotal.io sfrederick-org development SpaceManager
cf set-space-role sfrederick@pivotal.io sfrederick-org development SpaceAuditor
