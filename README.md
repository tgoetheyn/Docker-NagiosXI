Docker container for Nagios XI

At the moment this is a quick and dirty built, but it works.
If I find the time i wil make it a litte more "solid"

You can start the containwith te command:

  docker run -d -p 80:80 -p 5666:5666 -p 5667:5667 --name nagiosxi nagiosxi
  
Afterwards you can access the console at:

  http://YOUR_IP/nagiosxi/
