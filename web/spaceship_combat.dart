import 'dart:html';
import 'dart:async';
import 'package:box2d/box2d_browser.dart';
import 'dart:math' as Math;
import 'package:backy/backy.dart';
import 'package:darwin/darwin.dart';

PreElement experimentStatusEl;
PreElement globalStatusEl;
int STATUS_UPDATE_FREQ = 10;
int statusUpdateCounter = 0;

ShipCombatSituation currentSituation;

void main() {
  ShipBrainMode modeToTest = new RunAwayMode();
  
  experimentStatusEl = querySelector("#experiment-status");
  globalStatusEl = querySelector("#global-status");
  
  querySelector("#speed1x").onClick.listen((_) => 
      Demo.COMPUTATION_TO_SHOW_RATION = 1);
  querySelector("#speed10x").onClick.listen((_) => 
      Demo.COMPUTATION_TO_SHOW_RATION = 10);
  querySelector("#speed100x").onClick.listen((_) => 
      Demo.COMPUTATION_TO_SHOW_RATION = 100);
  
  querySelector("#putOnNoseTrain").onClick.listen((_) => 
      startGeneticAlgorithm(new PutOnNoseMode()));
//  querySelector("#putOnNoseTrain").onClick.listen((_) => 
//      startGeneticAlgorithm(new PutOnNoseMode()));
  querySelector("#runAwayTrain").onClick.listen((_) => 
      startGeneticAlgorithm(new RunAwayMode()));
  
  querySelector("#putOnNoseBest").onClick.listen((_) => 
      loopBestPhenotype(new PutOnNoseMode()));
//  querySelector("#runAwayBest").onClick.listen((_) => 
//      loopBestPhenotype(new RunAwayMode()));
  querySelector("#runAwayBest").onClick.listen((_) => 
      loopBestPhenotype(new RunAwayMode()));
  
  startGeneticAlgorithm(new PutOnNoseMode());
}

void loopBestPhenotype(ShipBrainMode modeToTest, [int i = 0]) {
  if (currentSituation != null) currentSituation.destroy();
  
  globalStatusEl.text = "Showing best for $modeToTest";
  
  print("Experiment $i");
  if (i >= modeToTest.setupFunctions.length) {
    new Future(() => loopBestPhenotype(modeToTest, 0));  // restart
    return;
  }
  
  ShipCombatSituation s = new ShipCombatSituation(
      fitnessFunction: modeToTest.iterativeFitnessFunction);
  currentSituation = s;
  var bodega = NeuroPilotSerialEvaluator._createBodega(s);
  var messenger = NeuroPilotSerialEvaluator._createMessenger(s);
  s.addShip(bodega, evaluatedShip: true);
  s.addShip(messenger);
  bodega.target = messenger;
  bodega.brainMode = modeToTest;
  bodega.brainMode.initializeBrain(bodega);
  bodega.brainMode.setBrainFromPhenotype(modeToTest.bestPhenotype);
  bodega.brainMode.setupFunctions[i](s);
  s.runTest().then((ShipCombatSituation s) {
    s.destroy();
    currentSituation = null;
    loopBestPhenotype(modeToTest, i + 1);
  });
}

void startGeneticAlgorithm(ShipBrainMode modeToTest) {
  if (currentSituation != null) currentSituation.destroy();
  
  int firstGenerationSize = 20;
  var firstGeneration = new Generation<NeuroPilotPhenotype>();
  
  List chromosomesList;
  
//chromosomesList = [
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,0.541511346181798,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-1,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-0.13176506082818373,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-1,-0.7147878509754113,-1,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,1,-0.65725713290285,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-0.9216289836952081,0.47062753360648335,0.37469768444830565,-1,-1,0.3153966366056331,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,0.6587097038459484,-0.5611031364488495,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-0.3347945708169964,-1,-1,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,-0.7195115405978962,1,0.3035244461389026,-1,-0.6065711605533946,0.9788210371967068,-1,0.4729139858876745,0.541511346181798,-0.65725713290285,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-0.10354538923425571,0.864497278944877,-1,0.47062753360648335,-0.13150060621124782,-1,-1,0.7553430133047478,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,1,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,0.8280652996809661,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,-0.39315162530495673,-1,-0.7147878509754113,-0.9726085102700306,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,1,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,0.2011619382456611,0.7246010776546117,0.6380770183191189,0.7904829313094861,1,1,0.8834377090394323,-0.8754321529101186,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-1,-0.7147878509754113,-0.9726085102700306,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.9498462671180838,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,0.541511346181798,-0.4919182529775268,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.06348132417499319,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-1,-1,-0.9726085102700306,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,0.541511346181798,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-0.10354538923425571,0.864497278944877,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,1,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.008346568529159937,0.5133826377775486,-1,-1,-0.9726085102700306,0.08415824234521363,1,1,0.16605023463709978,-1,1,-1,-1,-1,-1,0.8652467494936729,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,1,-0.65725713290285,-1,1,-0.8866056556621515,-0.8523225194769692,1,-0.5333387891790473,-1,0.864497278944877,-1,-0.277910830828376,-0.13150060621124782,-1,-1,0.06348132417499319,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,1,-0.8754321529101186,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.78988098930732,-0.1168442454317895,-0.3347945708169964,-0.7147878509754113,-1,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.7700196717181915,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.5066924590542783,-1,0.4729139858876745,1,-0.65725713290285,0.06441859930483651,0.6979449153249508,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-0.9216289836952081,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-1,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-0.8942846366337476,-1,-1,-0.24725117381601835,-1,-0.13176506082818373,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,-0.979022266626985,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-0.3347945708169964,-0.7147878509754113,-0.9726085102700306,0.08415824234521363,1,0.7789551787282964,0.16605023463709978,-1,1,-1,-1,-1,-1,0.8652467494936729,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.5066924590542783,-1,0.4729139858876745,0.541511346181798,-0.4919182529775268,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.8160589849826112,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-0.8754321529101186,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-0.3347945708169964,-0.44493613271947874,-1,0.08415824234521363,0.29851415279071425,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,0.541511346181798,-0.65725713290285,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-0.10354538923425571,0.864497278944877,-1,0.47062753360648335,-0.13150060621124782,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-0.8754321529101186,0.9804497013569788,1,1,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-1,-1,-0.9726085102700306,0.08415824234521363,1,0.7789551787282964,0.16605023463709978,-1,1,-1,-1,-1,-1,0.8652467494936729,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,1,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.864497278944877,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.06348132417499319,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,1,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.78988098930732,0.5133826377775486,-0.3347945708169964,-0.7147878509754113,-1,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,1,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.864497278944877,-1,0.47062753360648335,-0.13150060621124782,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-0.8754321529101186,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-0.3347945708169964,-0.7147878509754113,-0.9726085102700306,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,1,-0.65725713290285,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.7865191355328807,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,1,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-1,-1,-0.7919034242620708,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.5066924590542783,-1,-0.30394320371064953,0.541511346181798,-0.4919182529775268,0.06441859930483651,0.6979449153249508,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-0.10354538923425571,0.8160589849826112,-1,0.47062753360648335,-0.13150060621124782,-1,-1,0.06348132417499319,-0.3537152461532722,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-0.8942846366337476,-1,-1,-1,-0.5611031364488495,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.7380715932174475,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,-0.39315162530495673,-1,-0.7147878509754113,-0.9726085102700306,-0.1441293552639238,1,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,0.541511346181798,-0.4919182529775268,-1,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.06348132417499319,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.7904829313094861,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.35205790441081164,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-1,-1,-0.9726085102700306,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.9498462671180838,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,1,-0.4919182529775268,-0.37006445536450006,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-0.8754321529101186,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-0.8942846366337476,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-1,-0.7147878509754113,-1,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6694243114660696,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,0.541511346181798,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,1,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-1,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-1,-0.7147878509754113,-0.9726085102700306,0.08415824234521363,1,1,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.5066924590542783,-1,0.4729139858876745,0.541511346181798,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,0.9832376096636166,1,1,0.8834377090394323,-1,0.9804497013569788,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-0.13176506082818373,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,-0.979022266626985,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-0.3347945708169964,-0.44493613271947874,-1,0.08415824234521363,0.29851415279071425,0.7789551787282964,0.16605023463709978,-1,1,-1,-1,-1,-1,0.8652467494936729,-0.8860931172536737],
//[1,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,0.4729139858876745,1,-0.65725713290285,-1,1,-0.8866056556621515,-0.6747100617654358,1,-0.5333387891790473,-1,0.864497278944877,-1,0.47062753360648335,-0.0627640380482537,-1,-1,0.7553430133047478,-1,0.3936570980602092,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,1,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-0.24725117381601835,-1,-0.3660292371754801,0.45506549060346924,-0.039621954389641445,-0.4708800645739575,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8731240899732828,0.5133826377775486,-0.3347945708169964,-1,-0.9726085102700306,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-0.39428225190058974,0.6940740089925037,-0.8860931172536737],
//[0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.5066924590542783,-1,-0.30394320371064953,0.541511346181798,-0.4919182529775268,0.06441859930483651,0.6979449153249508,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-0.10354538923425571,0.2114781396876071,-1,0.47062753360648335,-0.13150060621124782,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-0.8754321529101186,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-0.8942846366337476,-1,-1,-1,-0.5611031364488495,-0.13176506082818373,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.7380715932174475,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-1,-0.7147878509754113,-1,-0.1441293552639238,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737]
//];
  
  var breeder = new GenerationBreeder<NeuroPilotPhenotype>(
      () => new NeuroPilotPhenotype())
    ..crossoverPropability = 0.8;
  var evaluator = new NeuroPilotSerialEvaluator(modeToTest);
  
  if (chromosomesList == null) {
    AIBox2DShip tempShip = NeuroPilotSerialEvaluator._createBodega(new ShipCombatSituation());
    tempShip.target = tempShip;
    for (int i = 0; i < firstGenerationSize; i++) {
      modeToTest.initializeBrain(tempShip);
      firstGeneration.members.add(
          new NeuroPilotPhenotype.fromBackyWeights(modeToTest.brain.weights));
    }
  } else {
    chromosomesList.forEach((List<num> ch) {
      NeuroPilotPhenotype ph = new NeuroPilotPhenotype();
      ph.genes = ch;
      firstGeneration.members.add(ph);
    });
  }
  
  var algo = new GeneticAlgorithm(firstGeneration, evaluator, breeder,
      statusf: (status) => globalStatusEl.text = status.toString());
  algo.runUntilDone()
  .then((_) {
    algo.generations.last.members
      .forEach((Phenotype ph) => print("${ph.genesAsString},"));
  });
}

class NeuroPilotPhenotype extends Phenotype<num> {
  NeuroPilotPhenotype();
  
  NeuroPilotPhenotype.fromBackyWeights(List<Weight> weightObjects) {
    List<List<List<num>>> weights = new List<List<List<num>>>(weightObjects.length);
    for (int i = 0; i < weightObjects.length; i++) {
      List<List<num>> array = weightObjects[i].weights;
      weights[i] = new List<List<num>>(array.length);
      for (int j = 0; j < array.length; j++) {
        weights[i][j] = new List<num>(array[j].length);
        for (int k = 0; k < array[j].length; k++) {
          weights[i][j][k] = array[j][k];
        }
      }
    }
    genes = weights.expand((List<List<num>> planes) => planes.expand((List<num> rows) => rows)).toList(growable: false);
  }
  
  List<num> genes;

  num mutateGene(num gene, num strength) {
    Math.Random random = new Math.Random();
    num delta = (random.nextDouble() * 2 - 1) * strength;
    return (gene + delta).clamp(-1, 1);
  }
}

class NeuroPilotSerialEvaluator extends PhenotypeSerialEvaluator<NeuroPilotPhenotype> {
  NeuroPilotSerialEvaluator(this.brainMode);
  
  /// The [ShipBrainMode] we are evaluating.
  final ShipBrainMode brainMode;
  
  static AIBox2DShip _createBodega(ShipCombatSituation s) {
    return new AIBox2DShip(s, 1.0, 3.0, new Vector2(0.0, 5.0),
          thrusters: [new Thruster(-1.5, -0.5, 1, 0),  // Main thrusters
                      new Thruster(-1.5,  0.5, 1, 0),
                      new Thruster( 1.5,    0, -0.5, 0), // Retarder
                      new Thruster(-1.5, -0.5, 0, 0.2), // Back maneuverability
                      new Thruster(-1.5,  0.5, 0, -0.2),
                      new Thruster( 1.5, -0.5, 0, 0.2),  // Front maneuverability
                      new Thruster( 1.5,  0.5, 0, -0.2)]);
  }
  
  static Box2DShip _createMessenger(ShipCombatSituation s) {
    return new Box2DShip(s, 0.3, 0.5, new Vector2(0.0, 15.0));
  }
  
  Future<num> runOneEvaluation(NeuroPilotPhenotype phenotype, int i) {
    print("Experiment $i");
    if (i >= brainMode.setupFunctions.length) {
      return new Future.value(null);
    }
    ShipCombatSituation s = new ShipCombatSituation(
        fitnessFunction: brainMode.iterativeFitnessFunction);
    currentSituation = s;
    var bodega = _createBodega(s);
    var messenger = _createMessenger(s);
    s.addShip(bodega, evaluatedShip: true);
    s.addShip(messenger);
    bodega.target = messenger;
    bodega.brainMode = brainMode;
    bodega.brainMode.initializeBrain(bodega);
    bodega.brainMode.setBrainFromPhenotype(phenotype);
    bodega.brainMode.setupFunctions[i](s);
    return s.runTest().then((ShipCombatSituation s) {
      if (s._destroyed) return null;
      s.destroy();
      currentSituation = null;
      return s.cummulativeScore;
    });
  }
}

/**
 * A function to be called before experiment. Makes sure everything is set
 * up in an 'interesting' way. Returns the [ShipCombatSituation].
 */
typedef SetupFunction(ShipCombatSituation s);

abstract class ShipBrainMode {
  static final Neuron neuron = new TanHNeuron();
  
  ShipBrainMode();
  
  void initializeBrain(AIBox2DShip ship) {
    neuron.bias = 1;
    outputNeuronsCount = ship.thrusters.length;
    brain = new Backy([inputNeuronsCount, 
                       // 'The optimal size of the hidden layer is usually 
                       // between the size of the input and size of the output 
                       // layers.'
                       (inputNeuronsCount + outputNeuronsCount) ~/ 2,
                       outputNeuronsCount], neuron);
  }
  
  Backy brain;
  
  List<num> _bestPhenotypeGenes;
  NeuroPilotPhenotype get bestPhenotype {
    if (_bestPhenotypeGenes == null) return null;
    var ph = new NeuroPilotPhenotype();
    ph.genes = _bestPhenotypeGenes;
    return ph;
  }
  
  int get inputNeuronsCount;
  int outputNeuronsCount;
  
  List<SetupFunction> get setupFunctions;
  
  /**
   * Takes the [ship] being evaluated, the [worldState] (when also evaluating
   * the effects the phenotype has on its environment, or when evaluating some
   * variables in relation to surroundings) and [userData] (an object that can
   * store state between calls to objective function).
   * 
   * The function must return a positive [num]. The lower the value, the better
   * fit. Returning [:0,0:] means the phenotype is performing perfectly (= is in
   * desired state in relation to its surroundings).
   * 
   * This function will be called periodically, and its return values will be
   * summed.
   */
  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
                               ShipCombatSituation worldState, 
                               [Object userData]);
  
  /**
   * Generates input for given [ship] and its [target] in a given situation [s].
   * This is feeded to the [brain]'s neural network.
   */
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s);
  
  /**
   * Takes control of the ship. 
   * 
   * Applies the results of the neural network by sending commands to different
   * systems of the ship, according to current situation.
   */
  void control(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s);
  
  void setBrainFromPhenotype(NeuroPilotPhenotype phenotype) {
    List<num> genes = phenotype.genes;
    int n = 0;
    for (int i = 0; i < brain.weights.length; i++) {
      for (int j = 0; j < brain.weights[i].weights.length; j++) {
        for (int k = 0; k < brain.weights[i].weights[j].length; k++) {
          brain.weights[i].weights[j][k] = genes[n];
          n++;
        }
      }
    }
    assert(n == genes.length);
  }
  
  /**
   * Takes a value and [min] and [max], and returns a number that is suitable
   * for [TanHNeuron] input. (Range from [:-1.0:] to [:1.0:].)
   * 
   * Values lower than [min] will be mapped to [:-1.0:], values higher than 
   * [max] will be mapped to [:1.0:]. Everything between will be mapped
   * lineary.
   * 
   * [min] can also be _higher_ than [max], in which case the function will
   * inverse. In other words, a [value] of [max] will be converted to [:-1.0:],
   * etc.
   */
  static num valueToNeuralInput(num value, num min, num max) {
    if (min == max || min == null || max == null) {
      throw new ArgumentError("The values of min and max must be different "
          "and not null (function called with $min, $max, respectivelly).");
    }
    bool inversed = min > max;
    
    if (value <= min) {
      return inversed ? 1.0 : -1.0;
    }
    if (value >= max) {
      return inversed ? -1.0 : 1.0;
    }
    
    return (value - min) / (max - min) * 2 - 1;
    // For value=3, min=0, max=10.
    // (3 - 0) / (10 - 0) * 2 - 1 = 0.3 * 2 - 1 = -0.4
    // For value=3, min=10, max=0.
    // (3 - 10) / (0 - 10) * 2 - 1 = (-7) / (-10) * 2 - 1 = 0.7 * 2 - 1 = 0.4
    // For value=3.5, min=4, max=3.
    // (3.5 - 4) / (3 - 4) * 2 - 1 = (-0.5) / (-1) * 2 - 1 = 0.5 * 2 - 1 = 0.0
  }
}

typedef num IterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
                                     ShipCombatSituation worldState, 
                                     [Object userData]);

/**
 * Only controls thrusters.
 */
abstract class ThrusterControllingShipBrainMode extends ShipBrainMode {
  ThrusterControllingShipBrainMode() : super();

  int outputNeuronsCount;
  
  /**
   * Takes control of the thrusters only.
   */
  void control(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s) {
    List<num> outputs = brain.use(getInputs(ship, target, s));
    assert(outputs.length == ship.thrusters.length);
    for (int i = 0; i < ship.thrusters.length; i++) {
      num force = ((outputs[i] + 1) / 2).clamp(0, 1);  // from <-1,1> to <0,1>
      ship.thrust(i, force);
    }
  }
}

class PutOnNoseMode extends ThrusterControllingShipBrainMode {
  PutOnNoseMode() : super();
  
  var _bestPhenotypeGenes = [1,0.9018464279413057,-1,-1,-1,1,-1,0.4136984574781215,-1,1,-0.742579672323123,-0.1908317505750039,0.5574536073173719,-1,-0.5296056136247094,1,0.3080163790918309,-0.022654338670871743,-0.3029914580544195,-0.7269177099906681,0.66321054623383,-0.9528884710051799,0.9312112351519395,-0.3138999404790046,0.5662556386739184,-0.07198920052360114,-1,-1,1,0.5800448338026072,0.469708722442443,1,1,-1,-0.5362791814941343,-0.40971072656896323,1,-0.08507525764205126,0.5048425278209785,0.19752286324384793,-0.22698805827085566,0.5740932416289573,0.6496256559898081,-1,0.037887718857197994,0.7869484594487615,-0.029936157128147345,0.28259970204508034,-0.33842683170428467,-1,1,0.19198573035876998,-0.1641794051381047,-0.207066541945774,0.5646929924520327,1,1,-1,0.09965951411735019,-0.012063975706213315,0.4224939056320067,0.026021830040641403,-0.43483123157928105,-0.9760319991964792,0.8348596923808211,0.20873481336001976,1,0.7556703921722707,-1,-1,-1,0.5128700532702966,-0.3409815693678979,-1,-0.1527288170577148,1,0.16677463033387863,-1];

  int inputNeuronsCount = 6;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s) {
    if (target == null) throw "Cannot put nose on null target.";
    List<num> inputs = new List(inputNeuronsCount);
    
    num angVel = ship.body.angularVelocity;
    inputs[0] = ShipBrainMode.valueToNeuralInput(angVel, 0, 2);
    inputs[1] = ShipBrainMode.valueToNeuralInput(angVel, 0, -2);
    inputs[2] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVectorTo(target).length, 0, 50);
    num angle = ship.getAngleTo(target);
    inputs[3] = ShipBrainMode.valueToNeuralInput(angle, 0, Math.PI * 2);
    inputs[4] = ShipBrainMode.valueToNeuralInput(angle, 0, - Math.PI * 2);
    inputs[5] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVelocityTo(target).length, 0, 5);
    
    return inputs;
  }

  List<SetupFunction> setupFunctions = [
      (ShipCombatSituation s) {
        print("- to the left");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 4);
      },
      (ShipCombatSituation s) {
        print("- to the right");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), 3 * Math.PI / 4);
      },
      (ShipCombatSituation s) {
        print("- back with impulse");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
        s.ship.body.applyLinearImpulse(new Vector2(2.0, 0.0), new Vector2(0.0, -1.0));
      },
      (ShipCombatSituation s) {
        print("- back slightly off");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2 + 0.1);
      }
  ];
  
  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
                               ShipCombatSituation worldState,
                               [Object userData]) {
    num angleScore = ship.getAngleTo(target).abs();
    num angularScore = ship.body.angularVelocity.abs();
    num relativeScore = ship.getRelativeVelocityTo(target).length;
    num absoluteScore = 
        ship.body.getLinearVelocityFromLocalPoint(new Vector2(0.0, 0.0)).length;
    
    num fitness = 
        (10 * angleScore + angularScore + relativeScore + absoluteScore);
    
    if (ship.body.contactList != null) {
      fitness += 50000;
    }
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, target, worldState);
      experimentStatusEl.text = """ 
          Angle (${ship.getAngleTo(target).toStringAsFixed(2)}) ${angleScore < 0.5 ? "*": ""}
          AnguV (${ship.body.angularVelocity.toStringAsFixed(2)})
          RelV  (${ship.getRelativeVelocityTo(target).length.toStringAsFixed(2)})
          AbsV  (${absoluteScore.toStringAsFixed(2)})
          SCORE = ${fitness.toStringAsFixed(2)}
          CUMSC = ${worldState.cummulativeScore.toStringAsFixed(2)}
          INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
          OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
          """;
          statusUpdateCounter = 0;
    }
    return fitness; 
  }
}

class RunAwayMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 6;

  var _bestPhenotypeGenes = [0.656042246016904,-1,-0.24081318444856392,0.5744812279030207,0.2294102058580787,1,0.3035244461389026,-1,-1,0.9788210371967068,-1,-0.30394320371064953,0.541511346181798,-0.4919182529775268,0.06441859930483651,1,-0.8866056556621515,-0.1523101906619717,1,-0.5333387891790473,-1,0.2114781396876071,-1,0.47062753360648335,0.37469768444830565,-1,-1,0.7553430133047478,-1,0.8036223092026535,0.46107153121756195,0.5584411618106389,0.5880153611491499,-1,1,0.7246010776546117,0.6380770183191189,1,1,1,0.8834377090394323,-1,0.9034351422933586,1,0.7532839617435458,1,0.9569661327238526,-1,-1,-1,-1,-1,-1,-0.13176506082818373,0.45506549060346924,-0.039621954389641445,-0.4293651779480425,-0.6297581134691022,0.005330164394882431,1,-0.3925779880446416,-0.8135402410935644,0.5133826377775486,-1,-0.7147878509754113,-1,0.08415824234521363,1,0.7789551787282964,1,-1,1,-1,-1,-1,-1,0.6940740089925037,-0.8860931172536737];
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s) {
    List<num> inputs = new List<num>(inputNeuronsCount);
    
    num angVel = ship.body.angularVelocity;
    inputs[0] = ShipBrainMode.valueToNeuralInput(angVel, 0, 2);
    inputs[1] = ShipBrainMode.valueToNeuralInput(angVel, 0, -2);
    inputs[2] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVectorTo(target).length, 0, 50);
    num angle = ship.getAngleTo(target);
    inputs[3] = ShipBrainMode.valueToNeuralInput(angle, 0, Math.PI * 2);
    inputs[4] = ShipBrainMode.valueToNeuralInput(angle, 0, - Math.PI * 2);
    inputs[5] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVelocityTo(target).length, 0, 5);
    
    return inputs;
  }
  
  List<SetupFunction> setupFunctions = [
      (ShipCombatSituation s) {
        print("- to the left");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 4);
      },
      (ShipCombatSituation s) {
        print("- to the right");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), 3 * Math.PI / 4);
      },
      (ShipCombatSituation s) {
        print("- back with impulse");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
        s.ship.body.applyLinearImpulse(new Vector2(2.0, 0.0), new Vector2(0.0, -1.0));
      },
      (ShipCombatSituation s) {
        print("- front with impulse");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 2);
        s.ship.body.applyLinearImpulse(new Vector2(0.0, 2.0), new Vector2(0.0, -1.0));
      }
  ];

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s, [Object userData]) {
    num velocityScore = 1 / (ship.getRelativeVelocityTo(target).length + 1);
    num proximityScore = 1 / Math.pow((ship.getRelativeVectorTo(target).length + 1) / 100, 2);  // 1 / (x/100)^2
    num angleScore = Math.PI - ship.getAngleTo(target).abs();
    
    num fitness = velocityScore + proximityScore + angleScore;
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, ship.target, ship.situation);
      experimentStatusEl.text = """ 
Velo (${velocityScore.toStringAsFixed(2)})
Prox (${proximityScore.toStringAsFixed(2)})
Angl (${angleScore.toStringAsFixed(2)}) ${angleScore < 0.5 ? "*" : ""}
SCORE = ${fitness.toStringAsFixed(2)}
CUMSC = ${s.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
      """;
      statusUpdateCounter = 0;
    }
    
    if (ship.body.contactList != null) {
      fitness += 50000;
    }
    
    return fitness;
  }

}

//num runAwayFitnessFunction(NeuroPilotPhenotype phenotype, 
//                             ShipCombatSituation s, 
//                             [Object userData]) {

//}

class ShipCombatSituation extends Demo {
  /** Constructs a new BoxTest. */
  ShipCombatSituation({this.fitnessFunction, this.maxTimeToRun: 1000}) 
      : super("Box test", new Vector2(0.0, 0.0)) {
    assert (world != null);
  }
  
  void initialize() {
    // Already initialized in constructor.
  }
  
  /**
   * The list of aiShips in the situation. If [fitnessFunction] is provided,
   * the _first_ ship is evaluated (not the others).
   */
  Set<AIBox2DShip> _aiShips = new Set<AIBox2DShip>();
  AIBox2DShip ship;
  
  void addShip(Box2DShip ship, {bool evaluatedShip: false}) {
    if (ship is AIBox2DShip) {
      _aiShips.add(ship);
      if (evaluatedShip) {
        this.ship = ship;
      }
    }
    bodies.add(ship.body);
  }
  
  /// Number of iterations to run this simulation. When set to [:null:], runs
  /// infinitely.
  num maxTimeToRun;
  num currentTime = 0;
  
  IterativeFitnessFunction fitnessFunction;
  num cummulativeScore = 0;
  
  Map userData = {};

  Completer<ShipCombatSituation> _completer = 
      new Completer<ShipCombatSituation>();
  
  Future runTest() {
    initializeAnimation();
    runAnimation(updateCallback);
    return _completer.future;
  }
  
  bool updateCallback(num time) {
    _aiShips.forEach((AIBox2DShip ship) => ship.applyBrain());
    currentTime += 1;
    if (maxTimeToRun != null && currentTime > maxTimeToRun) {
      _completer.complete(this);
      return false; 
    }
    if (fitnessFunction != null) {
      num score = fitnessFunction(ship, ship.target, this, userData);
      if (score == null) throw "Fitness function returned a null value.";
      if (score.isInfinite) {
        cummulativeScore = double.INFINITY;
        _completer.complete(this);
        return false;
      }
      cummulativeScore += score;
    }
    return true; // continue
  }
}

class Box2DShip {
  final ShipCombatSituation situation;
  Body body;
  final List<Thruster> thrusters;
  
  Box2DShip(this.situation, num length, num width, Vector2 position,
      {num initialAngle: 0,
       this.thrusters: const []}) {
    // Create shape
    final PolygonShape shape = new PolygonShape();
    shape.setAsBoxWithCenterAndAngle(width, length, new Vector2.zero(), 0.0);

    // Define fixture (links body and shape)
    final FixtureDef activeFixtureDef = new FixtureDef();
    activeFixtureDef.restitution = 0.5;
    activeFixtureDef.density = 0.05;
    activeFixtureDef.shape = shape;

    // Define body
    final BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.linearDamping = 0.2;
    bodyDef.angularDamping = 0.2;
    bodyDef.position = position;

    // Create body and fixture from definitions
    body = situation.world.createBody(bodyDef);
    body.createFixture(activeFixtureDef);
    
    body.setTransform(position, initialAngle.toDouble());
  }
  
  /**
   * Burns the thruster number [thrusterIndex] with [relativeForce] of its
   * [Thruster.maxForce].
   */
  void thrust(int thrusterIndex, num relativeForce) {
    if (thrusterIndex > thrusters.length) throw "No such thruster number $thrusterIndex.";
    
    Thruster thruster = thrusters[thrusterIndex];
    Matrix2 rotm = new Matrix2.rotation(-body.angle);
    body.applyForce(thruster.maxForce.scaled(relativeForce.toDouble()).postmultiply(rotm), 
        body.getWorldPoint(thruster.localPosition));
  }
  
  static final Vector2 ORIGIN = new Vector2.zero();
  static final Vector2 FORWARD = new Vector2(1.0, 0.0);
  static final Vector2 RIGHT = new Vector2(0.0, 1.0);
  
  Vector2 getRelativeVectorTo(Box2DShip target) => 
      body.getLocalPoint(target.body.position);
  num getAngleTo(Box2DShip target) {
    Vector2 relativeVectorToTarget = getRelativeVectorTo(target);
    return Math.acos(relativeVectorToTarget.dot(FORWARD) /
        (FORWARD.length * relativeVectorToTarget.length)) *
        (relativeVectorToTarget.dot(RIGHT) > 0 ? 1 : -1);
  }
  /**
   * Returns the velocity vector of the other ship as seen from this ship.
   */
  Vector2 getRelativeVelocityTo(Box2DShip target) {
    return body.getLinearVelocityFromLocalPoint(ORIGIN)
        .sub(target.body.getLinearVelocityFromLocalPoint(ORIGIN));
  }
}

class AIBox2DShip extends Box2DShip {
  AIBox2DShip(ShipCombatSituation situation, num length, num width, 
      Vector2 position, {num initialAngle: 0, List thrusters: const[]}) : 
        super(situation, length, width, position, thrusters: thrusters, initialAngle: initialAngle) {
  }
  
  Box2DShip target;
  
  /**
   * The current AI mode in charge of the ship. Examples: "steer towards point",
   * "stop", "run away", "face other ship", 
   *  
   * If [:null:], the ship is in manual mode.
   */
  ShipBrainMode brainMode;
  
  void applyBrain() {
    if (brainMode != null) {
      brainMode.control(this, target, situation);
    }
  }
}

class Thruster {
  final Vector2 localPosition;
  final Vector2 maxForce;
  Thruster(num x, num y, num maxForwardThrust, num maxLateralThrust) :
    localPosition = new Vector2(x.toDouble(), y.toDouble()),
    maxForce = new Vector2(maxForwardThrust.toDouble(), maxLateralThrust.toDouble()); 
}


/**
 * An abstract class for any Demo of the Box2D library.
 */
abstract class Demo {
  /** All of the bodies in a simulation. */
  List<Body> bodies = new List<Body>();

  /** The default canvas width and height. */
  static const int CANVAS_WIDTH = 900;
  static const int CANVAS_HEIGHT = 600;

  /** Scale of the viewport. */
  static const double _VIEWPORT_SCALE = 10.0;

  /** The gravity vector's y value. */
  static const double GRAVITY = -10.0;

  /** The timestep and iteration numbers. */
  static const num TIME_STEP = 1/30;
  static const int VELOCITY_ITERATIONS = 10;
  static const int POSITION_ITERATIONS = 10;

  /** The drawing canvas. */
  CanvasElement canvas;

  /** The canvas rendering context. */
  CanvasRenderingContext2D ctx;

  /** The transform abstraction layer between the world and drawing canvas. */
  ViewportTransform viewport;

  /** The debug drawing tool. */
  DebugDraw debugDraw;

  /** The physics world. */
  World world;

  /** Frame count for fps */
  int frameCount;

  /** HTML element used to display the FPS counter */
  Element fpsCounter;

  /** Microseconds for world step update */
  int elapsedUs;

  /** HTML element used to display the world step time */
  Element worldStepTime;

  // TODO(dominich): Make this library-private once optional positional
  // parameters are introduced.
  double viewportScale;

  // For timing the world.step call. It is kept running but reset and polled
  // every frame to minimize overhead.
  Stopwatch _stopwatch;

  Demo(String name, [Vector2 gravity, this.viewportScale = _VIEWPORT_SCALE]) {
//    _stopwatch = new Stopwatch()..start();
    bool doSleep = true;
    if (null == gravity) gravity = new Vector2(0.0, GRAVITY);
    world = new World(gravity, doSleep, new DefaultWorldPool());
  }

  static int COMPUTATION_TO_SHOW_RATION = 1;
  
  /** Advances the world forward by timestep seconds. */
  void step(num timestamp, [Function updateCallback]) {
    if (_destroyed) return;
    
    bool shouldContinue = true;
    for (int i = 0; i < COMPUTATION_TO_SHOW_RATION; i++) {
      world.step(TIME_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
      
      if (updateCallback != null) {
        shouldContinue = updateCallback(1);
        if (!shouldContinue) {
          break;
        }
      }
    }

    // Clear the animation panel and draw new frame.
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    world.drawDebugData();

    if (shouldContinue) {
      new Future(() {
        step(1, updateCallback);
      });
    }
    
//    window.requestAnimationFrame((num time) {
//      if (updateCallback != null) {
//        bool cont = updateCallback(time);
//        if (!cont) {
//          return;
//        }
//      }
//      step(time, updateCallback);
//    });
  }

  /**
   * Creates the canvas and readies the demo for animation. Must be called
   * before calling runAnimation.
   */
  void initializeAnimation() {
    // Setup the canvas.
    canvas = new Element.tag('canvas');
    canvas.width = CANVAS_WIDTH;
    canvas.height = CANVAS_HEIGHT;
    document.body.nodes.add(canvas);
    ctx = canvas.getContext("2d");

    // Create the viewport transform with the center at extents.
    final extents = new Vector2(CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2);
    viewport = new CanvasViewportTransform(extents, extents);
    viewport.scale = viewportScale;

    // Create our canvas drawing tool to give to the world.
    debugDraw = new CanvasDraw(viewport, ctx);

    // Have the world draw itself for debugging purposes.
    world.debugDraw = debugDraw;

    frameCount = 0;
//    new Timer.periodic(new Duration(seconds: 1), (Timer t) {
//        fpsCounter.innerHtml = frameCount.toString();
//        frameCount = 0;
//    });
//    new Timer.periodic(new Duration(milliseconds: 200), (Timer t) {
//        worldStepTime.innerHtml = "${elapsedUs / 1000} ms";
//    });
  }
  
  bool _destroyed = false;
  
  void destroy() {
    canvas.remove();
    _destroyed = true;
  }

  void initialize();

  /**
   * Starts running the demo as an animation using an animation scheduler.
   */
  void runAnimation([Function updateCallback]) {
    step(1, updateCallback);
  }
}