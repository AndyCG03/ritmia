import javax.net.ssl.*;
import java.net.*;
public class TlsProbe {
 public static void main(String[] args) throws Exception {
  var connection=(HttpsURLConnection)URI.create("https://dl.google.com/android/maven2/master-index.xml").toURL().openConnection();
  connection.setConnectTimeout(15000);connection.setReadTimeout(15000);
  System.out.println("TLS status: "+connection.getResponseCode());
 }
}
