import java.nio.file.*;
import java.security.KeyStore;
import java.security.cert.CertificateFactory;
public class BuildTrustStore {
 public static void main(String[] args)throws Exception{
  var store=KeyStore.getInstance("JKS");store.load(null,"changeit".toCharArray());
  try(var input=Files.newInputStream(Path.of(args[0]))){
   var certificates=CertificateFactory.getInstance("X.509").generateCertificates(input);int i=0;
   for(var cert:certificates)store.setCertificateEntry("windows-"+i++,cert);
   try(var output=Files.newOutputStream(Path.of(args[1]))){store.store(output,"changeit".toCharArray());}
   System.out.println("Local build trust store: "+i+" Windows root certificates");
  }
 }
}
