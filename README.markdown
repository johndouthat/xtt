XTT is a time tracker: think private 'twitter' that counts the duration of status messages.

Created by ENTP, the folks behind Lighthouse, Warehouse, Beast and other neat things.

Licensed under the AGPL v3

Getting Started
===============

1. Create config/database.yml, using a MySQL database. Using sqlite doesn't work due to the code using mysql-specific timezone conversion functions.
2. Create config/xtt.yml. Refer to config/xtt.example.yml
3. Create the log directory and make it world-writable
4. Run `rake gems:install` to ensure you have all the required gems, such as Tinder
5. Create the database with `rake db:create`
6. Populate the database with `rake db:schema:load`, then `rake db:migrate`
7. Start the server with ./script/server
8. Add a user at http://<your host>/signup
9. If you don't get a confirmation email (which you likely won't if you don't have the mail sending configured), check log/development.log for a copy of the confirmation email that would have been sent to you. copy and paste the activation url from it into the browser toolbar (should look like the following: http://tt.entp.com/activate/db61f839776898cedee72fcb9f87465d797e2e93 - of course, replace tt.entp.com with your dev server address.)

Going into Production
===============
1. If you're going into production and need to configure ActionMailer to use something other than simple sendmail, add those configuration options to config/environments/production.rb
2. Execute and monitor `script/runner "Xtt.aimbot_main_loop"`.