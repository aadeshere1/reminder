# Google Calendar Event Creator


## Installation
```
git clone https://github.com/aadeshere1/reminder.git ~/.reminder
cd ~/.reminder
bundle install
mv reminder.rb reminder
chmod 755 reminder
ln -s $PWD/reminder /usr/local/bin
```

Go to google developer console and create new service. Give Calendar API access.
Create and download credential for service account.
Save it and place it on your PC.

`export GCP_CONFIG_PATH="/your-location/credential.json"`
Also update your email in line 82

## Usage
reminder '2019-01-01' '2:13PM' 'Setup PC for my mother because I am a developer but for family I am just a guy who repairs electronics.'