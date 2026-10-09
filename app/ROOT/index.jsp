<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>DevOps Demo</title></head>
<body style="font-family:sans-serif;text-align:center;margin-top:80px">
  <h1>Apache Tomcat on AWS EKS</h1>
  <p>Served by pod: <b><%= java.net.InetAddress.getLocalHost().getHostName() %></b></p>
  <p>Built and deployed automatically by Jenkins CI/CD.</p>
</body>
</html>
