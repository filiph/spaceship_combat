import 'dart:html';
import 'dart:svg';
import 'dart:async';
import 'package:box2d/box2d_browser.dart';
import 'dart:math' as Math;
import 'package:backy/backy.dart';
import 'dart:convert';

PreElement statusEl;
int STATUS_UPDATE_FREQ = 10;
int statusUpdateCounter = 0;

void main() {
//  DivElement el = querySelector("#sample_container_id");
//  runExperiment();
  statusEl = querySelector("#status");
  
  var firstGeneration = new Generation<NeuroPilotPhenotype>();
  
  var temp = new ShipCombatSituation();
  for (int i = 0; i < 10; i++) {
    var bodega = new AIBox2DShip(temp, 1.0, 3.0, new Vector2(0.0, 5.0),
        thrusters: [new Thruster(-1.5, -0.5, 1, 0),  // Main thrusters
                    new Thruster(-1.5,  0.5, 1, 0),
                    new Thruster( 1.5,    0, -0.5, 0), // Retarder
                    new Thruster(-1.5, -0.5, 0, 0.2), // Back maneuverability
                    new Thruster(-1.5,  0.5, 0, -0.2),
                    new Thruster( 1.5, -0.5, 0, 0.2),  // Front maneuverability
                    new Thruster( 1.5,  0.5, 0, -0.2)]);
    firstGeneration.members.add(new NeuroPilotPhenotype.fromBackyWeights(bodega.brain.weights));
  }
  
//  var chromosomesList = [
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.2729798002334917,-0.2618105300513593,-0.39465680849813195,-0.6821390977246923,0.09157283162513305,-0.8617846740789133,0.5704188760245328,0.018703348664954746,0.9729127929415612,-0.4970918893185078,0.8676996932136967,0.38582047317354035,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.37287202043750833,-0.6466107766911856,-0.18237421242792845,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5094571051934814,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.20792224158515837,-0.6084893980352217],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.30393318680541653,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8617846740789133,0.5742204405281485,0.0056265506192918965,0.9401957600913926,-0.5494274952653522,0.8973602446949617,0.3711713752274686,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.34705345195742987,-0.6412059880093307,-0.18237421242792845,0.8542243299567541,0.6799213198414816,-0.47724294967224046,0.5054019256925771,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.14713526069584393,-0.6213829565879563],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.2729798002334917,-0.2618105300513593,-0.39465680849813195,-0.6821390977246923,0.09157283162513305,-0.8617846740789133,0.5704188760245328,0.018703348664954746,0.9729127929415612,-0.4970918893185078,0.8676996932136967,0.38582047317354035,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.37287202043750833,-0.6466107766911856,-0.1374986293980649,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5054019256925771,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.20792224158515837,-0.6213829565879563],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.26278088919170645,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8617846740789133,0.5742204405281485,0.0056265506192918965,0.9401957600913926,-0.5494274952653522,0.8973602446949617,0.3711713752274686,0.794420037364894,0.7573612280758607,-0.7499203928895684,0.516463775787708,-0.34705345195742987,-0.6466107766911856,-0.20724600350702632,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5054019256925771,-0.35303236266389526,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.18251472624316437,-0.6084893980352217],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.30393318680541653,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8656006370277267,0.5742204405281485,0.0056265506192918965,0.9401957600913926,-0.5494274952653522,0.8973602446949617,0.3711713752274686,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.34705345195742987,-0.6412059880093307,-0.18237421242792845,0.8542243299567541,0.648494116203664,-0.47724294967224046,0.5094571051934814,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.18251472624316437,-0.5803557671010685],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.30393318680541653,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8617846740789133,0.5742204405281485,-0.02908614289616622,0.9401957600913926,-0.5494274952653522,0.8973602446949617,0.3711713752274686,0.81789371586318,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.34705345195742987,-0.6412059880093307,-0.18237421242792845,0.8542243299567541,0.648494116203664,-0.47724294967224046,0.5094571051934814,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.18251472624316437,-0.6213829565879563],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.26278088919170645,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8617846740789133,0.5063508023338368,0.0056265506192918965,0.9462451827307707,-0.5023218367355032,0.8235807259454534,0.4229038701758987,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.3827103863172347,-0.6412059880093307,-0.18237421242792845,0.863589350076097,0.648494116203664,-0.47724294967224046,0.4877876223691064,-0.3223562369564429,0.8505192819767402,0.4583396046210889,-0.04506251362334977,0.18251472624316437,-0.6213829565879563],
//    [0.5338831508396709,-0.27290856156850263,-0.5881070607739927,-0.5738774338213097,-0.30393318680541653,-0.2605416575155488,-0.4080266008983807,-0.6980599584986366,0.09157283162513305,-0.8617846740789133,0.5742204405281485,0.0056265506192918965,0.9153944806045896,-0.5494274952653522,0.8973602446949617,0.3711713752274686,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.34705345195742987,-0.6466107766911856,-0.20724600350702632,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5054019256925771,-0.35303236266389526,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.18251472624316437,-0.6213829565879563],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.2729798002334917,-0.2618105300513593,-0.4299875435816166,-0.6821390977246923,0.09157283162513305,-0.8617846740789133,0.5704188760245328,0.0056265506192918965,0.9401957600913926,-0.5494274952653522,0.8973602446949617,0.3465851427590538,0.794420037364894,0.8032962022371507,-0.7499203928895684,0.516463775787708,-0.37287202043750833,-0.6466107766911856,-0.18237421242792845,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5054019256925771,-0.3196442711717523,0.8490938458219532,0.4907323097392185,-0.04506251362334977,0.20792224158515837,-0.6084893980352217],
//    [0.5338831508396709,-0.23075206143342747,-0.5881070607739927,-0.5738774338213097,-0.26278088919170645,-0.2605416575155488,-0.4080266008983807,-0.6776741706956604,0.042005789175389635,-0.8617846740789133,0.5742204405281485,0.018703348664954746,0.9729127929415612,-0.4970918893185078,0.8676996932136967,0.38582047317354035,0.794420037364894,0.8032962022371507,-0.7184782186057139,0.516463775787708,-0.34705345195742987,-0.6466107766911856,-0.20724600350702632,0.8542243299567541,0.648494116203664,-0.4627089475426728,0.5215782133084469,-0.35303236266389526,0.8490938458219532,0.4907323097392185,-0.08459026660192756,0.18251472624316437,-0.6213829565879563]
//  ];
//  
//  chromosomesList.forEach((List<num> ch) {
//    NeuroPilotPhenotype ph = new NeuroPilotPhenotype();
//    ph.genes = ch;
//    firstGeneration.members.add(ph);
//  });
  
  var evaluator = new NeuroPilotSerialEvaluator();
  var breeder = new SimpleNeuroPilotGenerationBreeder();
  
  var algo = new GeneticAlgorithm(firstGeneration, evaluator, breeder);
  algo.runUntilDone()
  .then((_) {
    algo.generations.last.members.forEach(print);
  });
}

class GeneticAlgorithm<T extends Phenotype> {
  final int GENERATION_SIZE;
  final int MAX_EXPERIMENTS = 10000;
  final num THRESHOLD_RESULT = 0.01;
  final int MAX_GENERATIONS_IN_MEMORY = 100;
  
  int currentExperiment = 0;
  
  List<Generation<T>> generations = new List<Generation>();
  Iterable<T> get population => generations.expand((Generation<T> gen) => gen.members);
  final PhenotypeEvaluator evaluator;
  final GenerationBreeder breeder;
  
  GeneticAlgorithm(Generation firstGeneration, this.evaluator, this.breeder) 
      : GENERATION_SIZE = firstGeneration.members.length {
    generations.add(firstGeneration);
  }
  
  Completer _doneCompleter;
  Future runUntilDone() {
    _doneCompleter = new Completer();
    _evaluateNextGeneration();
    return _doneCompleter.future;
  }
  
  void _evaluateNextGeneration() {
    evaluateLastGeneration()
    .then((_) {
      print("Generation #${generations.length} evaulation done. Results:");
      num generationCummulative = 0;
      num generationBest = double.INFINITY;
      generations.last.members.forEach((T member) {
        print("- ${member.result.toStringAsFixed(2)}");
        generationCummulative += member.result;
        if (member.result < generationBest) generationBest = member.result;
      });
      print("- ${generationCummulative.toStringAsFixed(2)} TOTAL");
      print("- ${generationBest.toStringAsFixed(2)} BEST");
      print("---");
      if (currentExperiment >= MAX_EXPERIMENTS) {
        print("All experiments done ($currentExperiment)");
        _doneCompleter.complete();
        return;
      }
      if (generations.last.members
          .any((T ph) => ph.result < THRESHOLD_RESULT)) {
        print("One of the phenotypes got over the threshold.");
        _doneCompleter.complete();
        return;
      }
      _createNewGeneration();
      _evaluateNextGeneration();
    });
  }
  
  void _createNewGeneration() {
    print("CREATING NEW GENERATION");
    generations.add(breeder.breedNewGeneration(generations));
    print("var newGen = [");
    generations.last.members.forEach((ph) => print("${ph.genesAsString},"));
    print("];");
    while (generations.length > MAX_GENERATIONS_IN_MEMORY) {
      print("- exceeding max generations, removing one from memory");
      generations.removeAt(0);
    }
  }
  
  int memberIndex;
  void _evaluateNextGenerationMember() {
    T currentPhenotype = generations.last.members[memberIndex];
    evaluator.evaluate(currentPhenotype)
    .then((num result) {
      currentPhenotype.result = result;
      
      currentExperiment++;
      memberIndex++;
      if (memberIndex < generations.last.members.length) {
        _evaluateNextGenerationMember();
      } else {
        _generationCompleter.complete();
        return;
      }
    });
  }
  
  Completer _generationCompleter;
  Future evaluateLastGeneration() {
    _generationCompleter = new Completer();
    
    memberIndex = 0;
    _evaluateNextGenerationMember();
    
    return _generationCompleter.future;
  }
}

class Generation<T extends Phenotype> {
  List<T> members = new List<T>();
}

abstract class GenerationBreeder<T extends Phenotype> {
  num mutationRate = 0.05;
  num mutationStrength = 0.10;
  
  Generation<T> breedNewGeneration(List<Generation> precursors);
  
  /**
   * Picks two phenotypes from the pool at random, compares them, and returns
   * the one with the better fitness.
   */
  T getRandomTournamentWinner(List<T> pool) {
    Math.Random random = new Math.Random();
    T first = pool[random.nextInt(pool.length)];
    T second;
    while (true) {
      second = pool[random.nextInt(pool.length)];
      if (second != first) break;
    }
    assert(first.result != null);
    assert(second.result != null);
    if (first.result < second.result) {
      return first;
    } else {
      return second;
    }
  }
  
  void mutate(T phenotype, {num mutationRate, num mutationStrength}) {
    if (mutationRate == null) mutationRate = this.mutationRate;
    if (mutationStrength == null) mutationStrength = this.mutationStrength;
    Math.Random random = new Math.Random();
    for (int i = 0; i < phenotype.genes.length; i++) {
      if (random.nextDouble() < mutationRate) {
        phenotype.genes[i] = phenotype.mutateGene(phenotype.genes[i], mutationStrength);
      }
    }
  }
  
  /**
   * Returns a [List] of length 2 (2 children), each having a List of genes
   * created by crossing over parents' genes.
   */
  List<List<Object>> crossoverParents(T a, T b, {int crossoverPointsCount: 2}) {
    assert(crossoverPointsCount < a.genes.length - 1);
    int length = a.genes.length;
    assert(length == b.genes.length);
    Set<int> crossoverPoints = new Set<int>();

    Math.Random random = new Math.Random();
    // Genes:   0 1 2 3 4 5 6
    // Xpoints:  0 1 2 3 4 5
    while (crossoverPoints.length < crossoverPointsCount) {
      crossoverPoints.add(random.nextInt(length - 1));
    }
    List<Object> child1genes = new List(length);
    List<Object> child2genes = new List(length);
    bool crossover = false;
    for (int i = 0; i < length; i++) {
      if (!crossover) {
        child1genes[i] = a.genes[i];
        child2genes[i] = b.genes[i];
      } else {
        child1genes[i] = b.genes[i];
        child2genes[i] = a.genes[i];
      }
      if (crossoverPoints.contains(i)) {
        crossover = !crossover;
      }
    }
    return [child1genes, child2genes];
  }
   
}

class SimpleNeuroPilotGenerationBreeder extends GenerationBreeder<NeuroPilotPhenotype> {
  
  Generation<NeuroPilotPhenotype> breedNewGeneration(List<Generation> precursors) {
    Generation<NeuroPilotPhenotype> newGen = new Generation<NeuroPilotPhenotype>();
    List<NeuroPilotPhenotype> pool = precursors.last.members.toList(growable: false);
    pool.sort((NeuroPilotPhenotype a, NeuroPilotPhenotype b) => a.result - b.result);
    int length = precursors.last.members.length;
    // Elitism
    NeuroPilotPhenotype clone1 = new NeuroPilotPhenotype();
    clone1.genes = pool.first.genes;
    print("Cloning the elite (with result ${pool.first.result}): $clone1");
    newGen.members.add(clone1);
    // Crossover breeding
    while (newGen.members.length < length) {
      NeuroPilotPhenotype parent1 = getRandomTournamentWinner(pool);
      NeuroPilotPhenotype parent2 = getRandomTournamentWinner(pool); // TODO: make sure it's not duplicate?
      print("Breeding parents with results ${parent1.result} and ${parent2.result}");
      NeuroPilotPhenotype child1 = new NeuroPilotPhenotype();
      NeuroPilotPhenotype child2 = new NeuroPilotPhenotype();
      List<List<num>> childrenGenes = crossoverParents(parent1, parent2);
      assert(childrenGenes.length == 2);
      child1.genes = childrenGenes[0];
      child2.genes = childrenGenes[1];
      newGen.members.add(child1);
      newGen.members.add(child2);
    }
    // Remove the phenotypes over length.
    while (newGen.members.length > length) {
      newGen.members.removeLast();
    }
    newGen.members.skip(1)  // Do not mutate elite.
      .forEach((NeuroPilotPhenotype ph) => mutate(ph));
    return newGen;
  }
}

abstract class PhenotypeEvaluator<T extends Phenotype> {
  PhenotypeEvaluator();
  Completer _completer;
  Future<num> evaluate(T phenotype);
}

abstract class PhenotypeSerialEvaluator<T extends Phenotype> 
      extends PhenotypeEvaluator<T> {
  Future<num> runOneEvaluation(T phenotype, int experimentIndex);
  
  void _next(T phenotype, int experimentIndex) {
    runOneEvaluation(phenotype, experimentIndex)
    .then((num result) {
      if (result == null) {
        print("Cummulative result for phenotype: $cummulativeResult");
        _completer.complete(cummulativeResult);
      } else if (result.isInfinite) {
        print("Result for experiment #$experimentIndex: FAIL\nFailing phenotype");
        _completer.complete(double.INFINITY);
      } else {
        cummulativeResult += result;
        print("Result for experiment: $result (cummulative: $cummulativeResult)");
        _next(phenotype, experimentIndex + 1);
      }
    });
  }
  
  num cummulativeResult;
  
  Future<num> evaluate(T phenotype) {
    print("Evaluating $phenotype");
    cummulativeResult = 0;
    _completer = new Completer();
    _next(phenotype, 0);
    return _completer.future;
  }
}

abstract class Phenotype<T> {
  List<T> genes;
  num result = null;
  
//  Phenotype<T> clone() {
//    Phenotype<T> copy = new Phenotype<T>();
//    copy.genes = new List<T>.from(genes, growable: false);
//  }
  
  T mutateGene(T gene, num strength);
  
  toString() => "Phenotype<$genesAsString>";
  
  String get genesAsString => JSON.encode(genes);
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
  
//  List<List<List<num>>> weights;
  
//  List<num> get genes => weights.expand((List<List<num>> planes) => planes.expand((List<num> rows) => rows)).toList(growable: false);
//  
//  set genes(List<num> value) {
//    int n = 0;
//    for (int i = 0; i < weights.length; i++) {
//      for (int j = 0; j < weights[i].length; j++) {
//        for (int k = 0; k < weights[i][j].length; k++) {
//          weights[i][j][k] = value[n];
//          n++;
//        }
//      }
//    }
//    assert(n == value.length);
//  }

  num mutateGene(num gene, num strength) {
    Math.Random random = new Math.Random();
    num delta = (random.nextDouble() * 2 - 1) * strength;
    return (gene + delta).clamp(-1, 1);
  }
}

class NeuroPilotSerialEvaluator extends PhenotypeSerialEvaluator<NeuroPilotPhenotype> {
  
  List<SetupFunction> setupFunctions = [
      (ShipCombatSituation s) {
        print("- to the left");
        s.bodega.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 4);
      },
//      (ShipCombatSituation s) {
//        print("- to the right");
//        s.bodega.body.setTransform(new Vector2(0.0, 0.0), 3 * Math.PI / 4);
//      },
//      (ShipCombatSituation s) {
//        print("- back");
//        s.bodega.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
//      },
      (ShipCombatSituation s) {
        print("- back slightly off");
        s.bodega.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2 + 0.1);
      }
  ];
  
  Future<num> runOneEvaluation(NeuroPilotPhenotype phenotype, int i) {
    print("Experiment $i");
    if (i >= setupFunctions.length) {
      return new Future.value(null);
    }
    ShipCombatSituation s = 
        new ShipCombatSituation(scoreOutcomeFunction: scorePutOnNose, 
            phenotype: phenotype);
    setupFunctions[i](s);
    return s.runTest().then((ShipCombatSituation s) {
      s.destroy();
      return s.cummulativeScore;
    });
  }
}




typedef void SetupFunction(ShipCombatSituation s);

//void runExperiment() {
//  List<Weight> weights;
//  if (records.length > generationSize) {
//    print("== CREATING MUTANT ==");
//    records.sort((ExperimentRecord a, ExperimentRecord b) => b.finalScore - a.finalScore);
//    ExperimentRecord winner = records[new Math.Random().nextInt(generationSize)];
//    weights = winner.weights;
//  } else {
//    weights = null;
//  }
//  
//  List<ExperimentRecord> phenotypeRecords = new List();
//  
//  Future.wait(setupFunctions.map((SetupFunction setupFunction) {
//    ShipCombatSituation s = 
//        new ShipCombatSituation(scoreOutcomeFunction: scorePutOnNose, phenotype: weights);
//    setupFunction(s);
//    return s.runTest();
//  })).then((List<ShipCombatSituation> situations) {
//    situations.forEach((ShipCombatSituation s) {
//      num score = scorePutOnNose(s);
//      print("Score: $score");
//      print("Angular Velocity: ${s.bodega.body.angularVelocity}");
//      num lengthsProduct = 1 * s.bodega.relativeVectorToTarget.length;
//      print("Angle: ${s.bodega.angleToTarget}");
//      
//      phenotypeRecords.add(new ExperimentRecord(s.bodega.brain.getWeights(), score, s.currentTime));
//      
//      s.destroy();
//    });
//    
//    phenotypeRecords.sort((ExperimentRecord a, ExperimentRecord b) => a.finalScore - b.finalScore);
//    
//    // Take the words record
//    records.add(phenotypeRecords.first);
//    
//    currentExperiment++;
//    if (currentExperiment < maxExperiments) {
//      runExperiment();
//    } else {
//      print("=== END ===");
//      records.forEach(print);
//    }
//  });
//  
//}

class ExperimentRecord {
  num finalScore;
  num timeToAchieve;
  List<Weight> weights;
  ExperimentRecord(this.weights, this.finalScore, this.timeToAchieve);
  List weightsToList() => weights.map((Weight w) => w.weights).toList(growable: false);
  String toString() {
    return "Experiment: score = $finalScore, timeToAchieve = $timeToAchieve\n"
        "${JSON.encode(weightsToList())}\n\n";
  }
}

num scorePutOnNose(ShipCombatSituation s) {
  num angleScore = s.bodega.angleToTarget.abs();
  num angularScore = s.bodega.body.angularVelocity.abs();
  num relativeScore = s.bodega.relativeVelocityToTarget.length;
  
  num score = (Math.pow(10 * angleScore, 2) + angularScore + relativeScore);
  
  if (s.world.contactCount > 0) {
//    return double.INFINITY;  // Autofail.
    score += 500000;
  }
  
//  print(score);
  statusUpdateCounter++;
  if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
    var inputs = s.bodega.getInputs();
    statusEl.text = """ 
Angle (${s.bodega.angleToTarget.toStringAsFixed(2)}) ${angleScore < 0.5 ? "*": ""}
AnguV (${s.bodega.body.angularVelocity.toStringAsFixed(2)})
RelV  (${s.bodega.relativeVelocityToTarget.length.toStringAsFixed(2)})
SCORE = ${score.toStringAsFixed(2)}
CUMSC = ${s.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${s.bodega.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
""";
    statusUpdateCounter = 0;
  }
  return score; 
}

typedef num ShipCombatFitnessFunction(ShipCombatSituation situation);

class ShipCombatSituation extends Demo {
  /** Constructs a new BoxTest. */
  ShipCombatSituation({this.scoreOutcomeFunction, this.maxTimeToRun: 1000,
      this.phenotype}) : super("Box test", new Vector2(0.0, 0.0)) {
    initialize();
  }
  
  /**
   * Parent's weights.
   */
  NeuroPilotPhenotype phenotype;
  
  num maxTimeToRun;
  num currentTime = 0;
  
  ShipCombatFitnessFunction scoreOutcomeFunction;
  num cummulativeScore = 0;

  Completer<ShipCombatSituation> _completer = new Completer<ShipCombatSituation>();
  
  Future runTest() {
    initializeAnimation();
    runAnimation(updateCallback);
    return _completer.future;
  }
  
  bool updateCallback(num time) {
    bodega.applyBrain();
    currentTime += 1;
    if (currentTime > maxTimeToRun) {
      _completer.complete(this);
      return false; 
    }
    if (scoreOutcomeFunction != null) {
      num score = scoreOutcomeFunction(this);
      if (score.isInfinite) {
        cummulativeScore = double.INFINITY;
        _completer.complete(this);
        return false;
      }
      cummulativeScore += score;
    }
    return true; // continue
  }

  void initialize() {
    assert (null != world);
    //_createGround();
    bodega = new AIBox2DShip(this, 1.0, 3.0, new Vector2(0.0, 5.0),
        thrusters: [new Thruster(-1.5, -0.5, 1, 0),  // Main thrusters
                    new Thruster(-1.5,  0.5, 1, 0),
                    new Thruster( 1.5,    0, -0.5, 0), // Retarder
                    new Thruster(-1.5, -0.5, 0, 0.2), // Back maneuverability
                    new Thruster(-1.5,  0.5, 0, -0.2),
                    new Thruster( 1.5, -0.5, 0, 0.2),  // Front maneuverability
                    new Thruster( 1.5,  0.5, 0, -0.2)]);
    // Add to list
    bodies.add(bodega.body);
    
    messenger = new Box2DShip(this, 0.3, 0.5, new Vector2(0.0, 15.0));
    // Add to list
    bodies.add(messenger.body);
    
    bodega.target = messenger;
    
    if (phenotype != null) {
      _copyFromPhenotype(phenotype, bodega.brain.weights);
    }
    
//    print(bodega.brain.weights.first.weights);
//    var trainer = new Trainer(backy: bodega.brain, maximumReapeatingCycle: 2000, precision: .1);
//    trainer.addTrainingCase(bodega.getInputs(), [0,0,0,1]);
//    print(trainer.trainOnlineSets());
//    print(bodega.brain.weights.first.weights);
  }
  
  void _copyFromPhenotype(NeuroPilotPhenotype phenotype, List<Weight> weights) {
    List<num> genes = phenotype.genes;
    int n = 0;
    for (int i = 0; i < weights.length; i++) {
      for (int j = 0; j < weights[i].weights.length; j++) {
        for (int k = 0; k < weights[i].weights[j].length; k++) {
          weights[i].weights[j][k] = genes[n];
          n++;
        }
      }
    }
    assert(n == genes.length);
  }
  

  void _createGround() {
    // Create shape
    final PolygonShape shape = new PolygonShape();

    // Define body
    final BodyDef bodyDef = new BodyDef();
    bodyDef.position.setValues(0.0, 0.0);

    // Create body
    final Body ground = world.createBody(bodyDef);

    // Set shape 3 times and create fixture on the body for each
    shape.setAsBox(50.0, 0.4);
    ground.createFixtureFromShape(shape);
    shape.setAsBoxWithCenterAndAngle(0.4, 50.0, new Vector2(-10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    shape.setAsBoxWithCenterAndAngle(0.4, 50.0, new Vector2( 10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);

    // Add composite body to list
    bodies.add(ground);
  }

  AIBox2DShip bodega;
  Box2DShip messenger;
  
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
    bodyDef.position = position;

    // Create body and fixture from definitions
    body = situation.world.createBody(bodyDef);
    body.createFixture(activeFixtureDef);
    
    body.setTransform(position, initialAngle.toDouble());
    
    //body.applyForce(new Vector2(0.0, -100.0), body.getWorldPoint(new Vector2(0.0, 1.0)));
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
}

class AIBox2DShip extends Box2DShip {
  AIBox2DShip(ShipCombatSituation situation, num length, num width, 
      Vector2 position, {num initialAngle: 0, List thrusters: const[]}) : 
        super(situation, length, width, position, thrusters: thrusters, initialAngle: initialAngle) {
    var neuron = new TanHNeuron();
    neuron.bias = 1;
    brain = new Backy([getInputs().length, /*getInputs().length - 1,*/ thrusters.length], neuron);
  }
  
  Box2DShip target;
  Backy brain;
  
  final Vector2 FORWARD = new Vector2(1.0, 0.0);
  final Vector2 RIGHT = new Vector2(0.0, 1.0);
  Vector2 get relativeVectorToTarget => body.getLocalPoint(target.body.position);
  num get angleToTarget => 
      Math.acos(relativeVectorToTarget.dot(FORWARD) / (FORWARD.length * relativeVectorToTarget.length)) *
      (relativeVectorToTarget.dot(RIGHT) > 0 ? 1 : -1);
  Vector2 get relativeVelocityToTarget => 
      body.getLinearVelocityFromLocalPoint(new Vector2(0.0, 0.0)).sub(target.body.getLinearVelocityFromLocalPoint(new Vector2(0.0, 0.0)));
  
  List<num> getInputs() {
    List<num> inputs = new List();
    num angVel = body.angularVelocity.clamp(-2, 2); //<-2,2>
    inputs.add(angVel >= 0 ? angVel - 1  : -1);
    inputs.add(angVel <  0 ? -angVel - 1 : -1);
    if (target == null) {
      inputs.addAll([0,0,0,0]);
    } else {
      num lengthsProduct = 1 * relativeVectorToTarget.length;
      inputs.add((relativeVectorToTarget.length / 50).clamp(0, 2) - 1);
      num angle = angleToTarget;
      inputs.add(angle >= 0 ? ( angleToTarget / Math.PI * 2 - 1) : -1);
      inputs.add(angle <  0 ? (-angleToTarget / Math.PI * 2 - 1) : -1);
      inputs.add((relativeVelocityToTarget.length / 5).clamp(0, 2) - 1);
    }
    return inputs;
  }
  
  void applyBrain() {
    List<num> outputs = brain.use(getInputs());
    for (int i = 0; i < thrusters.length; i++) {
      num force = ((outputs[i] + 1) / 2).clamp(0, 1);  // from <-1,1> to <0,1>
      thrust(i, force);
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

  /** Advances the world forward by timestep seconds. */
  void step(num timestamp, [Function updateCallback]) {
//    _stopwatch.reset();
    world.step(TIME_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
//    elapsedUs = _stopwatch.elapsedMicroseconds;

    // Clear the animation panel and draw new frame.
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    world.drawDebugData();
//    ++frameCount;

    new Future(() {
      if (updateCallback != null) {
        bool cont = updateCallback(1);
        if (!cont) {
          return;
        }
      }
      step(1, updateCallback);
    });
    
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
  
  void destroy() {
    canvas.remove();
  }

  void initialize();

  /**
   * Starts running the demo as an animation using an animation scheduler.
   */
  void runAnimation([Function updateCallback]) {
    step(1, updateCallback);
  }
}