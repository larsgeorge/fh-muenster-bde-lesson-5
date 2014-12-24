<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.NavigableSet" %>
<%@ page import="org.fhmuenster.bde.hush.ResourceManager" %>
<%@ page import="org.fhmuenster.bde.hush.HushUtil" %>
<%@ page import="org.fhmuenster.bde.hush.model.Counter" %>
<%@ page import="org.fhmuenster.bde.hush.model.ShortUrl" %>
<%@ page import="org.fhmuenster.bde.hush.model.ShortUrlStatistics" %>
<%
  String username = HushUtil.getOrSetUsername(request, response);
  ResourceManager rm = ResourceManager.getInstance();
  List<ShortUrlStatistics> stats = rm.getCounters().getUserShortUrlStatistics(username);

  if (stats != null && stats.size() > 0) {
%>
<div id="userstats">
  <p>
  <table id="tbluserstats">
    <thead>
    <tr>
      <th>No.</th>
      <th>Short URL</th>
      <th>Long URL</th>
      <th>Trend (last 30d)</th>
    </tr>
    </thead>
    <tbody>
    <%
      int rowNum = 0;
      for (ShortUrlStatistics stat : stats) {
        rowNum++;
        ShortUrl shortUrl = stat.getShortUrl();
        if (shortUrl == null) continue;
        String url = shortUrl.toString();
        String detailsUrl = url + "+";
        String longUrl = shortUrl.getLongUrl();
        StringBuffer sparkData = new StringBuffer();
        NavigableSet<?> data = stat.getCounters("clicks");
        if (data != null) {
          for (Object obj : data.descendingSet()) {
            Counter<Date, Double> counter = (Counter<Date, Double>) obj;
            if (sparkData.length() > 0) {
              sparkData.append(",");
            }
            sparkData.append(counter.getValue());
          }
        }
    %>
    <tr>
      <td class="rowNum"><%=rowNum%></td>
      <td class="shortUrl"><a href="<%= detailsUrl %>"><%= url %></a></td>
      <td class="longUrl"><a href="<%= longUrl %>" target=""><%= longUrl %></a></td>
      <td class="trend"><a href="<%= detailsUrl %>">
        <img alt="Recent Trend for <%= url %>"
             src="http://chart.apis.google.com/chart?cht=ls&chs=120x15&chd=t:<%=sparkData%>&chco=999999&chm=B,999999,0,0,0&chds=0,120"/></a>
      </td>
    </tr>
    <%
      }
    %>
    </tbody>
  </table>
  </p>
</div>
<% } %>
