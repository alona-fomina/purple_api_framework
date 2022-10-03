package conduitApp;


import com.intuit.karate.junit5.Karate;
class ConduitTest {

 @Karate.Test
 Karate testAll(){
return Karate.run().relativeTo(getClass());
 }
}