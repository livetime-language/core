# Add iOS target to capacitor app
npm i @capacitor/ios
npx cap add ios

# Add iOS target to .livetime/targets.tc
mkdir -p .livetime
grep -qs "npx cap run ios" .livetime/targets.lc || printf '\niOS\n\tTags: capacitor\n\tRunAfterBuild: npx cap run ios\n' >> .livetime/targets.lc
