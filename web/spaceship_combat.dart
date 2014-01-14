import 'dart:html';
import 'dart:svg';
import 'dart:async';
import 'package:box2d/box2d_browser.dart';
import 'dart:math' as Math;
import 'package:backy/backy.dart';
import 'dart:convert';

PreElement experimentStatusEl;
PreElement globalStatusEl;
int STATUS_UPDATE_FREQ = 10;
int statusUpdateCounter = 0;

void main() {
  
  ShipBrainMode modeToTest = new RunAwayMode();
  int firstGenerationSize = 20;
  
  experimentStatusEl = querySelector("#experiment-status");
  globalStatusEl = querySelector("#global-status");
  
  var firstGeneration = new Generation<NeuroPilotPhenotype>();
  
  List chromosomesList;
  
//chromosomesList = [
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,1,1,0.7726397737754036,1,1,1,0.7980289695356075,1,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.26234867615502977,-1,0.378781008508946,0.5873524885104711,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-1,-1,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,-0.5792083648812889,0.13985358372858947,0.5458434086683364,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,1,-0.500546507264007,0.4718962009712222,0.9976213657896074,1,0.7726397737754036,1,1,1,0.7980289695356075,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,1,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-0.8125987149593825,-1,-1,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.5458434086683364,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-1,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,0.21859766749567866,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-0.37240751925098503,-1,-1,-1,0.5731703138778093,-0.49507259784009294,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-0.9095477239963718,-0.032574928956002,-0.9073392278095036,-1,-1,-0.8934893935021047,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,1,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.1530207613804342,-1,0.378781008508946,0.5873524885104711,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-1,-0.8934893935021047,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,0.9976213657896074,1,0.7726397737754036,1,1,1,0.7980289695356075,1,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-1,-0.8125987149593825,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.5458434086683364,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-1,-0.21688472717480645,1,0.6419555137341351,1,0.9976213657896074,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-0.37240751925098503,-1,-1,-1,1,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-1,-1,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.5458434086683364,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-1,-0.21688472717480645,1,0.6419555137341351,1,0.9976213657896074,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-0.007193178836099934,-0.37240751925098503,-1,-1,-1,1,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-1,-1,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,0.7529422434946915,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.1530207613804342,-1,0.378781008508946,-0.017567504835124037,0.7894762222643672,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-0.8125987149593825,-0.5841145243328647,-0.9218319151328374,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,0.9976213657896074,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-0.9472186016933022,-0.1530207613804342,-1,0.378781008508946,-0.8089454836941354,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-1,-1,-1,-0.8934893935021047,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,1,1,0.7726397737754036,1,1,1,0.7980289695356075,1,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.26234867615502977,-1,0.378781008508946,0.5873524885104711,0.7894762222643672,0.9768982833586974,-1,0.005429625261560211,-1,-1,-1,-1,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,1,1,0.7726397737754036,1,1,0.4448077878004282,0.5341683329817353,1,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-0.9472186016933022,-0.1530207613804342,-1,0.378781008508946,0.5873524885104711,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.8945248582092347,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-1,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,1,1,0.7726397737754036,1,1,1,0.9032450238982612,1,0.6491073487784005,-1,-1,-0.23505463405078464,-1,-1,1,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.7894762222643672,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.8945248582092347,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,1,1,0.7726397737754036,1,1,0.7394903252833374,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-0.8087841500681365,-1,-1,0.9992616254638989,-0.9472186016933022,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-1,-0.8125987149593825,-0.4887307982271707,-1,-1,1,-0.25291277442450744,-1,0.3553448899007796,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,0.46399134380203777,0.9429699512951351,0.6419555137341351,1,0.7529422434946915,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-0.9472186016933022,-0.1530207613804342,-1,0.378781008508946,-0.017567504835124037,0.7894762222643672,0.9768982833586974,-1,-0.032574928956002,-1,-1,-0.5841145243328647,-0.9218319151328374,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,0.7529422434946915,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-0.9472186016933022,-0.1530207613804342,-1,0.378781008508946,-0.017567504835124037,0.7894762222643672,0.9768982833586974,-1,-0.032574928956002,-1,-1,-0.5841145243328647,-0.9218319151328374,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,0.9976213657896074,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.1530207613804342,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-1,-0.5841145243328647,-0.9218319151328374,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-1,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,0.7529422434946915,1,0.7726397737754036,0.8615569378766839,1,0.6259558185046195,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-1,-0.8125987149593825,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,0.4718962009712222,1,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-0.9472186016933022,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.19791213298224886,0.025560478560818556,-1,-1,-0.9218319151328374,-1,0.8976564181694153,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,0.13242487073349807,0.13985358372858947,0.14408907829056417,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,-0.21688472717480645,0.9429699512951351,0.6419555137341351,1,0.9976213657896074,1,0.7726397737754036,1,1,1,0.9032450238982612,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,0.5731703138778093,-1,-0.1530207613804342,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.9768982833586974,-1,-0.032574928956002,-0.9073392278095036,-0.8125987149593825,-1,-0.8934893935021047,-1,1,-0.25291277442450744,-1,1,1],
//[0.18394842079960316,0.5994950454153449,-0.5792083648812889,0.13985358372858947,0.5458434086683364,1,-0.011870642078618321,0.6430619229774432,-0.8411615742310568,0.08338355889437121,1,-0.7823039130704101,0.25256343411055027,1,0.6419555137341351,0.4718962009712222,1,1,0.7726397737754036,1,1,1,0.7980289695356075,0.8149971950635138,0.6491073487784005,-1,-1,-1,-1,-1,1,-1,-0.26234867615502977,-1,0.378781008508946,-0.017567504835124037,0.11934783738647381,0.17113904975917427,-1,-0.032574928956002,-0.9073392278095036,-0.8125987149593825,-1,-1,-1,1,-0.25291277442450744,-0.9903001996698513,1,1],
//];
  
  var breeder = new SimpleNeuroPilotGenerationBreeder()
    ..crossoverPropability = 0.8;
  var evaluator = new NeuroPilotSerialEvaluator(modeToTest);
  
  if (chromosomesList == null) {
    AIBox2DShip tempShip = evaluator._createBodega(new ShipCombatSituation());
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
  
  var algo = new GeneticAlgorithm(firstGeneration, evaluator, breeder);
  algo.runUntilDone()
  .then((_) {
    algo.generations.last.members
      .forEach((Phenotype ph) => print("${ph.genesAsString},"));
  });
}

class GeneticAlgorithm<T extends Phenotype> {
  final int GENERATION_SIZE;
  final int MAX_EXPERIMENTS = 20000;
  final num THRESHOLD_RESULT = 0.01;
  final int MAX_GENERATIONS_IN_MEMORY = 100;
  
  int currentExperiment = 0;
  int currentGeneration = 0;
  
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
      print("Applying niching to results.");
      breeder.applyFitnessSharingToResults(generations.last);
      print("Generation #$currentGeneration evaluation done. Results:");
      generations.last.members.forEach((T member) {
        print("- ${member.result.toStringAsFixed(2)}");
      });
      print("- ${generations.last.averageFitness.toStringAsFixed(2)} AVG");
      print("- ${generations.last.bestFitness.toStringAsFixed(2)} BEST");
      globalStatusEl.text = """
GENERATION #$currentGeneration
AVG  ${generations.last.averageFitness.toStringAsFixed(2)}
BEST ${generations.last.bestFitness.toStringAsFixed(2)}
""";
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
      currentGeneration++;
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
        generations.last.computeSummary();
        _generationCompleter.complete();
        return;
      }
    });
  }
  
  Completer _generationCompleter;
  
  /**
   * Evaluates the latest generation and completes when done.
   * 
   * TODO: Allow for multiple members being evaluated in parallel via
   * isolates.
   */
  Future evaluateLastGeneration() {
    _generationCompleter = new Completer();
    
    memberIndex = 0;
    _evaluateNextGenerationMember();
    
    return _generationCompleter.future;
  }
}

class Generation<T extends Phenotype> {
  List<T> members = new List<T>();
  
  /**
   * Filters the generation to phenotypes that are similar to [ph] as defined
   * by their Hamming distance being less than [radius].
   * 
   * This _includes_ the original [ph] (Because [ph]'s Hamming distance to 
   * itself is [:0:].)
   */
  Iterable<T> getSimilarPhenotypes(T ph, num radius) {
    return members
        .where((T candidate) => ph.computeHammingDistance(candidate) < radius);
  }
  
  num cummulativeFitness;
  num get averageFitness {
    if (cummulativeFitness == null) return null;
    return cummulativeFitness / members.length;
  }
  num bestFitness;
  
  /**
   * Computes [cummulativeFitness] and [bestFitness], assuming all members of
   * the population are scored.
   */
  void computeSummary() {
    cummulativeFitness = 0;
    bestFitness = double.INFINITY;
    members.forEach((T ph) {
      cummulativeFitness += ph.result;
      if (ph.result < bestFitness) bestFitness = ph.result;
    });
  }
}

abstract class GenerationBreeder<T extends Phenotype> {
  num mutationRate = 0.01;  // 0.01 means that every gene has 1% probability of mutating
  num mutationStrength = 1.0;  // 1.0 means any value can become any other value
  num crossoverPropability = 1.0;
  
  num fitnessSharingRadius = 0.1;
  num fitnessSharingAlpha = 1;
  
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
    
    if (first._resultWithFitnessSharingApplied != null && 
        second._resultWithFitnessSharingApplied != null) {
      // Fitness sharing was applied. Compare those numbers.
      if (first._resultWithFitnessSharingApplied < 
          second._resultWithFitnessSharingApplied) {
        return first;
      } else {
        return second;
      }
    }
    
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
   * 
   * The crossover only happens with [crossoverPropability]. Otherwise, exact
   * copies of parents are returned.
   */
  List<List<Object>> crossoverParents(T a, T b, {int crossoverPointsCount: 2}) {
    Math.Random random = new Math.Random();
    
    if (random.nextDouble() < (1 - crossoverPropability)) {
      // No crossover. Return genes as they are.
      return [new List.from(a.genes, growable: false),
              new List.from(b.genes, growable: false)];
    }
    
    assert(crossoverPointsCount < a.genes.length - 1);
    int length = a.genes.length;
    assert(length == b.genes.length);
    Set<int> crossoverPoints = new Set<int>();

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
  
  
  /**
   * Iterates over [members] and raises their fitness score according to
   * their uniqueness.
   * 
   * Algorithm as described in Jeffrey Horn: The Nature of Niching, pp 20-21.
   * http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.33.8352&rep=rep1&type=pdf
   */
  void applyFitnessSharingToResults(Generation generation) {
    generation.members.forEach((T ph) {
      num nicheCount = generation.getSimilarPhenotypes(ph, fitnessSharingRadius)
        .map((T other) => ph.computeHammingDistance(other))  // XXX: computing hamming distance twice (in getSimilarPhenotypes and here)
        .fold(0, (num sum, num distance) => 
            sum + 
            (1 - Math.pow(distance/fitnessSharingRadius, fitnessSharingAlpha)));
      // The algorithm is modified - we multiply the result instead of 
      // dividing it. (Because we count 0.0 as perfect fitness. The smaller
      // the result number, the fitter the phenotype.)
      ph._resultWithFitnessSharingApplied = ph.result * nicheCount;  
    });
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
      List<List<num>> childrenGenes = crossoverParents(parent1, parent2, crossoverPointsCount: parent1.genes.length ~/ 2);
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

/**
 * Takes the [phenotype] being evaluated, the [worldState] (when also evaluating
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
//typedef num IterativeFitnessFunction(Object worldState, 
//                                     [Object userData]);

// TODO: can be implemented as an Isolate
abstract class PhenotypeEvaluator<T extends Phenotype> {
  Object userData;
  Completer _completer;
  Future<num> evaluate(T phenotype);
}

abstract class PhenotypeSerialEvaluator<T extends Phenotype> 
      extends PhenotypeEvaluator<T> {
  /**
   * Runs one of the experiments to be performed on the given [phenotype].
   * Should complete with the result of the [IterativeFitnessFunction], or with
   * [:null:] when there are no other experiments to run.
   */
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
    userData = null;
    _completer = new Completer();
    _next(phenotype, 0);
    return _completer.future;
  }
}

abstract class Phenotype<T> {
  List<T> genes;
  num result = null;
  num _resultWithFitnessSharingApplied = null;
  
//  Phenotype<T> clone() {
//    Phenotype<T> copy = new Phenotype<T>();
//    copy.genes = new List<T>.from(genes, growable: false);
//  }
  
  T mutateGene(T gene, num strength);
  
  toString() => "Phenotype<$genesAsString>";
  
  String get genesAsString => JSON.encode(genes);
  
  /**
   * Returns the degree to which this chromosome has dissimilar genes with the
   * other. If chromosomes are identical, returns [:0.0:]. If all genes are 
   * different, returns [:1.0:].
   * 
   * Genes are considered different when they are not equal. There is no
   * half-different gene (which would make sense for [num] genes, for example).
   */
  num computeHammingDistance(Phenotype<T> other) {
    int length = genes.length;
    int similarCount = 0;
    for (int i = 0; i < genes.length; i++) {
      if (genes[i] == other.genes[i]) {
        similarCount++;
      }
    }
    return (1 - similarCount / length);
  }
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
  
  AIBox2DShip _createBodega(ShipCombatSituation s) {
    return new AIBox2DShip(s, 1.0, 3.0, new Vector2(0.0, 5.0),
          thrusters: [new Thruster(-1.5, -0.5, 1, 0),  // Main thrusters
                      new Thruster(-1.5,  0.5, 1, 0),
                      new Thruster( 1.5,    0, -0.5, 0), // Retarder
                      new Thruster(-1.5, -0.5, 0, 0.2), // Back maneuverability
                      new Thruster(-1.5,  0.5, 0, -0.2),
                      new Thruster( 1.5, -0.5, 0, 0.2),  // Front maneuverability
                      new Thruster( 1.5,  0.5, 0, -0.2)]);
  }
  
  Box2DShip _createMessenger(ShipCombatSituation s) {
    return new Box2DShip(s, 0.3, 0.5, new Vector2(0.0, 15.0));
  }
  
  Future<num> runOneEvaluation(NeuroPilotPhenotype phenotype, int i) {
    print("Experiment $i");
    if (i >= brainMode.setupFunctions.length) {
      return new Future.value(null);
    }
    ShipCombatSituation s = new ShipCombatSituation(
        fitnessFunction: brainMode.iterativeFitnessFunction);
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
      s.destroy();
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
  // [1,0.9018464279413057,-1,-1,-1,1,-1,0.4136984574781215,-1,1,-0.742579672323123,-0.1908317505750039,0.5574536073173719,-1,-0.5296056136247094,1,0.3080163790918309,-0.022654338670871743,-0.3029914580544195,-0.7269177099906681,0.66321054623383,-0.9528884710051799,0.9312112351519395,-0.3138999404790046,0.5662556386739184,-0.07198920052360114,-1,-1,1,0.5800448338026072,0.469708722442443,1,1,-1,-0.5362791814941343,-0.40971072656896323,1,-0.08507525764205126,0.5048425278209785,0.19752286324384793,-0.22698805827085566,0.5740932416289573,0.6496256559898081,-1,0.037887718857197994,0.7869484594487615,-0.029936157128147345,0.28259970204508034,-0.33842683170428467,-1,1,0.19198573035876998,-0.1641794051381047,-0.207066541945774,0.5646929924520327,1,1,-1,0.09965951411735019,-0.012063975706213315,0.4224939056320067,0.026021830040641403,-0.43483123157928105,-0.9760319991964792,0.8348596923808211,0.20873481336001976,1,0.7556703921722707,-1,-1,-1,0.5128700532702966,-0.3409815693678979,-1,-0.1527288170577148,1,0.16677463033387863,-1]

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
    
    if (worldState.world.contactCount > 0) {
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