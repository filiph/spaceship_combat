part of spaceship_combat;

class NeuroPilotPhenotype extends Phenotype<num> {
  NeuroPilotPhenotype();

  NeuroPilotPhenotype.fromBackyWeights(List<Weight> weightObjects) {
    List<List<List<num>>> weights =
        new List<List<List<num>>>(weightObjects.length);
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
    genes = weights
        .expand(
            (List<List<num>> planes) => planes.expand((List<num> rows) => rows))
        .toList(growable: false);
  }

  List<num> genes;

  num mutateGene(num gene, num strength) {
    Math.Random random = new Math.Random();
    num delta = (random.nextDouble() * 2 - 1) * strength;
    return (gene + delta).clamp(-1, 1);
  }
}

class NeuroPilotSerialEvaluator
    extends PhenotypeSerialEvaluator<NeuroPilotPhenotype> {
  NeuroPilotSerialEvaluator(this.brainMode);

  /// The [ShipBrainMode] we are evaluating.
  final ShipBrainMode brainMode;

  static AIBox2DShip _createBodega(ShipCombatSituation s) {
    return new AIBox2DShip(s, 1.0, 3.0, new Vector2(0.0, 15.0), thrusters: [
      new Thruster(-1.5, -0.5, 1, 0), // Main thrusters
      new Thruster(-1.5, 0.5, 1, 0),
      new Thruster(1.5, 0, -0.5, 0), // Retarder
      new Thruster(-1.5, -0.5, 0, -0.2), // Back maneuverability
      new Thruster(-1.5, 0.5, 0, 0.2),
      new Thruster(1.5, -0.5, 0, -0.2), // Front maneuverability
      new Thruster(1.5, 0.5, 0, 0.2)
    ]);
  }

  static Box2DShip _createMessenger(ShipCombatSituation s) {
    return new Box2DShip(s, 0.3, 0.5, new Vector2(0.0, 0.0));
  }

  Future<num> runOneEvaluation(NeuroPilotPhenotype phenotype, int i) {
    print("Experiment $i");
    if (i >= brainMode.setupFunctions.length) {
      return new Future.value(null);
    }
    ShipCombatSituation s = new ShipCombatSituation(
        fitnessFunction: brainMode.iterativeFitnessFunction,
        maxTimeToRun: brainMode.timeToEvaluate);
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
      if (s.destroyed) return null;
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
    brain = new Backy([
      inputNeuronsCount,
      // 'The optimal size of the hidden layer is usually
      // between the size of the input and size of the output
      // layers.'
      (inputNeuronsCount + outputNeuronsCount) ~/ 2,
      outputNeuronsCount
    ], neuron);
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
      ShipCombatSituation worldState, Object userData);

  /**
   * Number of simulation steps to evaluate. This should be enough for this
   * brain to do its thing and stay at the needed position.
   */
  int timeToEvaluate = 1000;

  /**
   * Generates input for given [ship] and its [target] in a given situation [s].
   * This is feeded to the [brain]'s neural network.
   * [userData] can be used to store information between runs of the function.
   */
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData);

  /**
   * Takes control of the ship.
   *
   * Applies the results of the neural network by sending commands to different
   * systems of the ship, according to current situation.
   */
  void control(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData);

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
    ShipCombatSituation worldState, Object userData);

/**
 * Only controls thrusters.
 */
abstract class ThrusterControllingShipBrainMode extends ShipBrainMode {
  ThrusterControllingShipBrainMode() : super();

  int outputNeuronsCount;

  /**
   * Takes control of the thrusters only.
   */
  void control(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) {
    List<num> outputs = brain.use(getInputs(ship, target, s, userData));
    assert(outputs.length == ship.thrusters.length);
    for (int i = 0; i < ship.thrusters.length; i++) {
      num force = ((outputs[i] + 1) / 2).clamp(0, 1); // from <-1,1> to <0,1>
      ship.thrust(i, force);
    }
  }
}

int STATUS_UPDATE_FREQ = 10;
int statusUpdateCounter = 0;

final List<SetupFunction> genericSetupFunctions = [
  (ShipCombatSituation s) {
    // Other ship on 10 o'clock
    s.ship.body.setTransform(new Vector2(0.0, -10.0), Math.PI / 4);
  },
  (ShipCombatSituation s) {
    // Other ship on 2 o'clock, farther away, with sideways impulse.
    s.ship.body.setTransform(new Vector2(5.0, -15.0), 3 * Math.PI / 4);
    s.ship.body.applyLinearImpulse(
        new Vector2(-2.0, 0.0), new Vector2(5.0, -15.0), true);
  },
  (ShipCombatSituation s) {
    // Other ship on 4 o'clock, with forward impulse.
    s.ship.body.setTransform(new Vector2(-1.0, 15.0), 3 * Math.PI / 4);
    s.ship.body.applyLinearImpulse(
        new Vector2(0.0, 1.0), new Vector2(-1.0, 15.0), true);
  },
  (ShipCombatSituation s) {
    // Other ship on 7 o'clock.
    s.ship.body.setTransform(new Vector2(-1.0, 15.0), Math.PI / 4);
  },
  (ShipCombatSituation s) {
    // Other ship on 12 o'clock, rotation.
    s.ship.body.setTransform(new Vector2(10.0, 10.0), -3 * Math.PI / 4);
    s.ship.body.applyLinearImpulse(
        new Vector2(2.0, 0.0), new Vector2(0.0, -1.0), true);
  }
];

class FaceOtherShipMode extends ThrusterControllingShipBrainMode {
  FaceOtherShipMode() : super();

  var _bestPhenotypeGenes = [
    1,
    -0.8947288889927001,
    1,
    -1,
    0.6327160347133203,
    0.24665732260677276,
    -0.2233863497038595,
    0.806936600492663,
    1,
    0.5315530523017835,
    -1,
    -1,
    0.8678781662411872,
    1,
    1,
    -0.0546314250982749,
    -0.13756947772991168,
    0.041207115198311106,
    -0.3809765990643985,
    0.15102248153623088,
    1,
    0.1863303420530329,
    -1,
    -0.26113185159655417,
    -0.8027139872115652,
    -0.8086453914239984,
    1,
    -1,
    1,
    0.6578546015311979,
    0.6312848290062352,
    -0.8417188951534516,
    -1,
    1,
    0.1340895506235107,
    -0.24755707368614144,
    -1,
    0.2500712719969076,
    0.9954598774613879,
    -0.7114729493005327,
    0.3350326613943715,
    -0.5340619171322079,
    -0.31935110525166177,
    0.47175806827987077,
    -1,
    1,
    0.4456456060013487,
    -1,
    0.16087548159755571,
    0.11121877164934513,
    0.5500417783689215,
    0.8565760062153371,
    1,
    -1,
    -0.012866529092330214,
    1,
    0.9152829010330614,
    0.984311549509991,
    1,
    0.3753402076632608,
    1,
    0.9065607352788665,
    0.2946421344533037,
    -1,
    0.01170929191634107,
    1,
    0.9393090017108612,
    -0.22700711668934348,
    0.10832938469128561,
    0.3788762343331249,
    -0.9031700016638191,
    0.2596441026121319,
    1,
    -1,
    -0.372209619145323,
    0.33160842233718646,
    -0.13635178137479476,
    -1,
    0.7118448911888058,
    -0.46320762416176287,
    -1,
    1,
    0.901549146261093,
    -1,
    1,
    -0.2248006524623143,
    -0.3621865144968872,
    0.8926302919628353,
    0.729756302121493,
    -0.005969583957413871,
    1,
    0.4888345025869445,
    -0.6041591995366333,
    1,
    0.732871326066836,
    0.4013212913953972,
    -0.5918025132043061,
    -0.24447976781250236,
    -1,
    0.2804673159301827,
    -1,
    -0.5400849335643256,
    0.9861375002411452,
    0.1399222533083777,
    0.07907169066863418
  ];

  int inputNeuronsCount = 8;

  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
          Object userData) =>
      AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions = genericSetupFunctions
    ..add((ShipCombatSituation s) {
      print("- back slightly off, target moving");
      s.ship.body.setTransform(new Vector2(0.0, 10.0), -Math.PI / 2 + 0.1);
      s.ships.last.body.applyLinearImpulse(
          new Vector2(-0.1, -0.2), new Vector2(0.0, -1.0), true);
    });

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
      ShipCombatSituation worldState, Object userData) {
    num angleScore = ship.getAngleTo(target).abs();
    num angularScore = ship.body.angularVelocity.abs();
    num relativeScore = ship.getRelativeVelocityTo(target).length;
    num consumptionScore = ship._currentPowerConsumption / 10;

    num fitness =
        (10 * angleScore + angularScore + relativeScore + consumptionScore);

    if (ship.body.getContactList() != null) {
      fitness += 50000;
    }

    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, target, worldState, userData);
      experimentStatusEl.text = """
Angle (${ship.getAngleTo(target).toStringAsFixed(2)}) ${angleScore < 0.5 ? "*": ""}
AnguV (${ship.body.angularVelocity.toStringAsFixed(2)})
RelV  (${ship.getRelativeVelocityTo(target).length.toStringAsFixed(2)})
Cons  (${consumptionScore.toStringAsFixed(2)})
AbsV  (---)
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

class RamMode extends ThrusterControllingShipBrainMode {
  RamMode() : super();

  var _bestPhenotypeGenes = [
    -0.2927897314550374,
    1,
    -0.3363057248708414,
    -1,
    -0.8435919118648196,
    1,
    0.5288788627400596,
    0.7706733946188098,
    -0.4543488007161587,
    -0.2917958497487527,
    -1,
    0.8597651199635767,
    -1,
    0.6121651221755153,
    1,
    -0.19411523013439091,
    1,
    0.8264745137839373,
    -0.7807990246559724,
    1,
    0.4965676701333319,
    0.2740452855076676,
    -1,
    1,
    0.43932181234534595,
    1,
    -0.17876037611469675,
    -1,
    -1,
    -0.2985238761128568,
    -0.036272677810098575,
    0.5635278770994434,
    1,
    0.5048676863870596,
    -0.4715913007407311,
    -1,
    1,
    0.4160364397865848,
    -1,
    -0.8295146470035142,
    -0.20428628365921409,
    1,
    0.03720512235236573,
    -0.8918936683468637,
    1,
    -0.8942535649447778,
    0.808670414180674,
    -0.7580789521744367,
    -1,
    0.15930657509843482,
    0.1918088074466633,
    1,
    -1,
    -0.7949637634332141,
    -0.697284975577144,
    0.5657055016776826,
    1,
    -0.5421329572293243,
    -0.6460197494514646,
    0.7759927349221789,
    -0.6083170897320767,
    -0.6531575798530906,
    0.3078092382951061,
    -0.54061894948777,
    -1,
    -1,
    1,
    1,
    0.15796275762466871,
    -0.8475472387074809,
    -1,
    0.05122514284152313,
    1,
    -0.5269111607766406,
    0.27311455272397,
    0.9519490765060927,
    -0.24285778277743697,
    -0.8057375013684673,
    -0.4110654200168262,
    0.10298202392335654,
    -0.7460375552060294,
    1,
    0.8530694669242933,
    -1,
    -0.4341239018057286,
    -1,
    0.17112828182067163,
    0.5097984668915931,
    1,
    0.17497250845607937,
    -1,
    -0.023740031072248202,
    -0.9919233309064241,
    1,
    -0.594657999468251,
    0.6139852733008135,
    1,
    -1,
    -1,
    -0.859063343467197,
    -0.01895219427971928,
    1,
    -1,
    -0.6705082189044571,
    0.09972258662371103
  ];

  int inputNeuronsCount = 8;

  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
          Object userData) =>
      AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions = genericSetupFunctions;

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
      ShipCombatSituation worldState, Object userData) {
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, target, worldState, userData);
      experimentStatusEl.text = """
Rammed (${(userData as Map).containsKey("rammed")})
AnguV (${ship.body.angularVelocity.toStringAsFixed(2)})
RelV  (${ship.getRelativeVelocityTo(target).length.toStringAsFixed(2)})
CUMSC = ${worldState.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
      """;
      statusUpdateCounter = 0;
    }

    if ((userData as Map).containsKey("rammed")) {
      return 0;
    }
    if (ship.body.getContactList() != null) {
      (userData as Map)["rammed"] = true;
      var score = ship.body.angularVelocity.abs() * 10; // prefer straight line
      score += ship.getAngleTo(target).abs() * 100; // prefer head on collision
      return score;
    }

    return 1 + ship._currentPowerConsumption / 10;
  }
}

class RunAwayMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 8;

  var _bestPhenotypeGenes = [
    0.24174205382236025,
    0.5970256984332207,
    -1,
    -0.8998453660058803,
    -0.16322539927719482,
    -0.8348079471316912,
    0.3699465105112172,
    1,
    1,
    -0.5653787218661799,
    1,
    -1,
    1,
    -0.7400398217610034,
    -0.9194194101215576,
    0.05321029801566968,
    -0.05932042979156327,
    0.032420419500704734,
    0.8265414662732853,
    -1,
    1,
    0.6878917290861299,
    -0.27109589395568023,
    -0.33565647752664796,
    0.3699575148434331,
    -1,
    -0.8295540548766744,
    -1,
    1,
    -0.5611415261459496,
    -0.041150636555764786,
    0.2502915036314126,
    0.2212064995687768,
    1,
    -1,
    -0.3428799764056587,
    -1,
    1,
    -1,
    -0.33583884555718635,
    1,
    -0.41249686481236214,
    0.9031864604137472,
    -1,
    1,
    -0.6841325444917865,
    -1,
    -0.39825072185818433,
    -0.4530049927531379,
    -0.06816038696290594,
    1,
    -0.7368723230896972,
    1,
    1,
    0.2785913828036177,
    0.27250984568263625,
    -0.3728694944107298,
    0.5777273265505356,
    1,
    0.6251397184215557,
    -0.7864251191495917,
    0.763739595212114,
    0.4705072430161188,
    -0.2994710435080561,
    1,
    1,
    1,
    -1,
    0.3039726959646383,
    -1,
    -1,
    -0.09183637899225561,
    -0.42045868062233205,
    -1,
    1,
    -1,
    -1,
    -0.5833899804389755,
    -0.6847011369445657,
    -1,
    -0.3294005281451946,
    0.33082704137792307,
    0.2236911577683971,
    -1,
    -0.18343077103914363,
    -0.9552892643186199,
    1,
    -0.12560922570798105,
    -0.7201160171208774,
    0.15627113326405717,
    1,
    -1,
    -0.21074493692586826,
    -0.11012162729571795,
    -0.9997018965899764,
    1,
    -0.9523907354380541,
    -1,
    0.7899533721352632,
    0.6525687938370968,
    1,
    0.3519982032372837,
    -1,
    0.6730358601444157,
    1
  ];

  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
          Object userData) =>
      AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions =
      new List<SetupFunction>.from(genericSetupFunctions)
        ..addAll([
          (ShipCombatSituation s) {
            print("- back with impulse");
            s.ship.body.setTransform(new Vector2(0.0, -15.0), -Math.PI / 2);
            s.ship.body.applyLinearImpulse(
                new Vector2(2.0, 0.0), new Vector2(0.0, -1.0), true);
          },
          (ShipCombatSituation s) {
            print("- front with impulse");
            s.ship.body.setTransform(new Vector2(0.0, -15.0), Math.PI / 2);
            s.ship.body.applyLinearImpulse(
                new Vector2(0.0, 2.0), new Vector2(0.0, -1.0), true);
          }
        ]);

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
      ShipCombatSituation s, Object userData) {
    num velocityScore = 1 / (ship.getRelativeVelocityTo(target).length + 1);
    num proximityScore = 1 /
        Math.pow((ship.getRelativeVectorTo(target).length + 1) / 100,
            2); // 1 / (x/100)^2
    num angleScore = Math.PI - ship.getAngleTo(target).abs();
    num consumptionScore = ship._currentPowerConsumption / 10;

    num fitness =
        velocityScore + proximityScore + angleScore + consumptionScore;

    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs =
          ship.brainMode.getInputs(ship, ship.target, ship.situation, userData);
      experimentStatusEl.text = """
Velo (${velocityScore.toStringAsFixed(2)})
Prox (${proximityScore.toStringAsFixed(2)})
Angl (${angleScore.toStringAsFixed(2)}) ${angleScore < 0.5 ? "*" : ""}
Cons (${consumptionScore.toStringAsFixed(2)})
SCORE = ${fitness.toStringAsFixed(2)}
CUMSC = ${s.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
      """;
      statusUpdateCounter = 0;
    }

    if (ship.body.getContactList() != null) {
      fitness += 50000;
    }

    return fitness;
  }
}

class DockLeftMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 8;

  static final DESIRED_DISTANCE = 5;

  var _bestPhenotypeGenes = [
    1,
    0.1488756009073815,
    0.06056975418757138,
    0.48512392793899073,
    -0.4839786106591055,
    0.7809382202576982,
    0.8154474745781635,
    1,
    -1,
    -0.6406865735984728,
    -0.39019333085872066,
    -0.9199216625267304,
    0.6319830606818968,
    -0.5094059226489578,
    -0.8817402896470559,
    -0.9160083726644914,
    0.6870063772976949,
    -1,
    0.2916448537359262,
    1,
    -0.39122105716735933,
    0.8644616158805765,
    -0.492936327109218,
    -0.2232650348196603,
    -0.9976906111347907,
    1,
    0.5519283782131095,
    0.6715476268049487,
    -0.7767671041103035,
    -1,
    0.9200508477726235,
    0.7581351084363412,
    -0.529733358335627,
    0.6324696005610719,
    1,
    -0.9726041047986513,
    0.35735723505606143,
    -0.6524951671299526,
    0.8480435867427323,
    0.9836408146868527,
    -0.7639215768057752,
    0.05228015917082107,
    -0.1740865059400949,
    1,
    0.23595423338856336,
    0.0736553850390067,
    1,
    1,
    1,
    0.20096152821366564,
    0.19274016981723885,
    0.1947704227675655,
    0.8171496871820063,
    1,
    0.16353550102482584,
    0.3613161474863449,
    -0.3797121187966843,
    0.15255855461317958,
    -1,
    -0.9370390408292251,
    1,
    0.1766985734167068,
    -0.7724241748881098,
    0.38226964366869054,
    -1,
    -0.3052011221284865,
    0.6369307811166005,
    0.1656745354620035,
    0.9025447052605688,
    0.6336998419449924,
    0.5569286474842483,
    -1,
    -0.8097815907096313,
    -0.31277335484403856,
    0.2729686035510708,
    1,
    0.12206815016903216,
    -0.5555153843128897,
    -0.6452414789286267,
    0.21069160442879054,
    -0.24620474796600988,
    0.7265918230855308,
    0.8898467830684651,
    0.6976589475766153,
    1,
    -0.6936952138586834,
    1,
    0.13799194697582884,
    -1,
    1,
    -1,
    0.6308097591605664,
    0.5171501261778777,
    -0.5164499748787004,
    -1,
    0.8731557913387415,
    -0.014734418429272811,
    1,
    1,
    0.9289183687022056,
    -1,
    -0.5531224631788354,
    -0.3376448722522356,
    0.5407180133144336,
    0.24910523635824577
  ];

  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
          Object userData) =>
      AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions =
      new List<SetupFunction>.from(genericSetupFunctions)
        ..addAll([
          (ShipCombatSituation s) {
            print("- back with impulse");
            s.ship.body.setTransform(new Vector2(0.0, 0.0), -Math.PI / 2);
            s.ship.body.applyLinearImpulse(
                new Vector2(2.0, 0.0), new Vector2(0.0, -1.0), true);
          },
          (ShipCombatSituation s) {
            print("- front with impulse");
            s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 2);
            s.ship.body.applyLinearImpulse(
                new Vector2(0.0, 2.0), new Vector2(0.0, -1.0), true);
          }
        ]);

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
      ShipCombatSituation s, Object userData) {
    num velocityScore = ship.getRelativeVelocityTo(target).length;
    num proximityScore =
        (ship.getRelativeVectorTo(target).length - DESIRED_DISTANCE).abs();
    num angle = ship.getAngleTo(target);
    num wantedAngle = -Math.PI / 2;
    num angleScore = (angle - wantedAngle).abs();
    num angVel = ship.body.angularVelocity.abs();
    num consumptionScore = ship._currentPowerConsumption / 10;

    num fitness =
        velocityScore + proximityScore + angleScore + angVel + consumptionScore;

    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs =
          ship.brainMode.getInputs(ship, ship.target, ship.situation, userData);
      experimentStatusEl.text = """
Velo (${velocityScore.toStringAsFixed(2)})
Prox (${proximityScore.toStringAsFixed(2)})
Angl (${(ship.getAngleTo(target) / Math.PI * 180).toStringAsFixed(2)}) ${angleScore < 0.5 ? "*" : ""}
SCORE = ${fitness.toStringAsFixed(2)}
CUMSC = ${s.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
""";
      statusUpdateCounter = 0;
    }

    if (ship.body.getContactList() != null) {
      if (velocityScore < 0.5) {
        fitness += 5000;
      } else {
        fitness += 50000;
      }
    }

    return fitness;
  }

  int timeToEvaluate = 2000;
}

class MaintainRelativePositionMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 8;

  var _bestPhenotypeGenes = [
    0.2368872170811296,
    -0.9299053054515156,
    -1,
    -0.5373850230577295,
    0.6615064240026916,
    0.45335011504634903,
    0.15706910542063146,
    -0.7799952539528088,
    0.9539114358119785,
    0.007510718531626104,
    -0.5922570555952236,
    0.8124783840559928,
    1,
    -0.6109147262680854,
    -0.5884970716530538,
    -1,
    1,
    -0.2340149044059876,
    -1,
    0.7694004959668699,
    1,
    0.9302089915774139,
    0.7034485070889147,
    0.0609995935672627,
    -0.19441907251278034,
    0.46542975536274067,
    -0.49839809329959794,
    0.9448485881274951,
    -0.2009643275679971,
    -1,
    -0.0525193649643203,
    0.5131846233367072,
    -1,
    -0.13819831165410257,
    0.09382797674444632,
    -0.7570887203853724,
    -0.16290909840106815,
    -0.2333049097256361,
    1,
    -0.12809188259982673,
    -0.7452380938408809,
    0.9237735513578091,
    -0.7508335822565626,
    -0.2177494816671517,
    1,
    1,
    0.7047066907337787,
    -0.16403618583987867,
    0.8525768443437385,
    -0.8386930507351855,
    0.16471898018184095,
    0.30432422800510306,
    0.5526562331079452,
    0.07352714164385254,
    0.4482586910466928,
    -0.42689914405597973,
    0.46792382156163725,
    0.555790054939636,
    -1,
    0.9965105273304153,
    1,
    0.3551958152086008,
    -0.07859482292660513,
    1,
    -0.9546247182039451,
    1,
    -0.1696082630354745,
    -0.26767899468428036,
    -1,
    0.9941059743057781,
    -0.4259590912890916,
    0.06661483970908866,
    -1,
    -0.8860360172008375,
    -1,
    1,
    -1,
    1,
    0.550013400664183,
    -0.4806402342816978,
    -0.20240506315108187,
    -1,
    1,
    1,
    0.5678265401515743,
    -1,
    0.8294882270527102,
    0.7823927045853305,
    -1,
    -0.8453970466831155,
    -0.8469155433696389,
    1,
    0.5726409924598195,
    -0.40771333823724576,
    0.1277732157234026,
    -1,
    -0.25673468948932965,
    -1,
    -0.3508117160157771,
    0.0705554178645531,
    -0.48970870081620577,
    0.6982400472868733,
    1,
    -0.03934517263407611,
    -0.16069566319969497
  ];

  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
          Object userData) =>
      AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions = [
    (ShipCombatSituation s) {
      // Default
    },
    (ShipCombatSituation s) {
      s.ship.body.setTransform(new Vector2(0.0, 0.0), -Math.PI / 2);
      s.ship.body.applyLinearImpulse(
          new Vector2(2.0, 0.0), new Vector2(0.0, -1.0), true);
    },
    (ShipCombatSituation s) {
      s.ship.body.setTransform(new Vector2(0.0, 0.0), -Math.PI / 2);
      s.ships.last.body.applyLinearImpulse(
          new Vector2(0.1, 0.0), s.ships.last.body.position, true);
    },
    (ShipCombatSituation s) {
      s.ships.last.body.applyLinearImpulse(
          new Vector2(-0.2, 0.0), s.ships.last.body.position, true);
    },
  ];

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
      ShipCombatSituation s, Object userData) {
    num velocityScore = ship.getRelativeVelocityTo(target).length;
    num angVel = ship.body.angularVelocity.abs();
    num consumptionScore = ship._currentPowerConsumption / 10;

    num fitness = 10 * velocityScore + angVel + consumptionScore;

    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs =
          ship.brainMode.getInputs(ship, ship.target, ship.situation, userData);
      experimentStatusEl.text = """
Velo (${velocityScore.toStringAsFixed(2)})
AngV (${(ship.body.angularVelocity).toStringAsFixed(2)})
Cons (${consumptionScore.toStringAsFixed(2)})
SCORE = ${fitness.toStringAsFixed(2)}
CUMSC = ${s.cummulativeScore.toStringAsFixed(2)}
INPT  = ${inputs.map((num o) => o.toStringAsFixed(2)).join(" ")}
OUTP  = ${ship.brainMode.brain.use(inputs).map((num o) => o.toStringAsFixed(2)).join(" ")}
      """;
      statusUpdateCounter = 0;
    }

    if (ship.body.getContactList() != null) {
      fitness += 50000;
    }

    return fitness;
  }
}

class ShipCombatSituation extends Demo {
  /** Constructs a new BoxTest. */
  ShipCombatSituation({this.fitnessFunction, this.maxTimeToRun: 1000})
      : super("Box test", simEl, new Vector2(0.0, 0.0)) {
    assert(world != null);
  }

  void initialize() {
    // Already initialized in constructor.
  }

  /**
   * The list of aiShips in the situation. If [fitnessFunction] is provided,
   * the _first_ ship is evaluated (not the others).
   */
  Set<AIBox2DShip> _aiShips = new Set<AIBox2DShip>();
  /**
   * This is _the_ ship being evaluated.
   */
  AIBox2DShip ship;

  /**
   * A list of all the ships in this simulation. It's ordered in the way those
   * ships were added.
   */
  List<Box2DShip> ships = new List<Box2DShip>();

  void addShip(Box2DShip ship, {bool evaluatedShip: false}) {
    if (ship is AIBox2DShip) {
      _aiShips.add(ship);
      if (evaluatedShip) {
        this.ship = ship;
      }
    }
    bodies.add(ship.body);
    ships.add(ship);
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
    num scale = 10.0;

    if (Demo.computationToShowRatio <= 10) {
      // Save some CPU on high speeds.
      debugDraw.setCamera(ship.body.position.x * scale + 450,
          ship.body.position.y * scale + 300, scale);
    }

    return true; // continue
  }
}

class Box2DShip {
  final ShipCombatSituation situation;
  Body body;
  final List<Thruster> thrusters;

  num _currentPowerConsumption = 0;

  Box2DShip(this.situation, num length, num width, Vector2 position,
      {num initialAngle: 0, this.thrusters: const []}) {
    // Create shape
    final PolygonShape shape = new PolygonShape();
    shape.setAsBox(width, length, new Vector2.zero(), 0.0);

    // Define fixture (links body and shape)
    final FixtureDef activeFixtureDef = new FixtureDef();
    activeFixtureDef.restitution = 0.5;
    activeFixtureDef.density = 0.05;
    activeFixtureDef.shape = shape;

    // Define body
    final BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.linearDamping = 0.1; // Reality is Unrealistic...
    bodyDef.angularDamping =
        0.2; // As above, plus let's count with stabilization jets...
    bodyDef.position = position;

    // Create body and fixture from definitions
    body = situation.world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(activeFixtureDef);

    body.setTransform(position, initialAngle.toDouble());
  }

  /**
   * Burns the thruster number [thrusterIndex] with [relativeForce] of its
   * [Thruster.maxForce].
   */
  void thrust(int thrusterIndex, num relativeForce) {
    if (thrusterIndex >
        thrusters.length) throw "No such thruster number $thrusterIndex.";

    Thruster thruster = thrusters[thrusterIndex];
    Matrix2 rotm = new Matrix2.rotation(-body.getAngle());
    body.applyForce(
        thruster.maxForce.scaled(relativeForce.toDouble()).postmultiply(rotm),
        body.getWorldPoint(thruster.localPosition));

    _currentPowerConsumption += thruster.maxForce.length * relativeForce;

    situation.debugDraw.drawSolidCircle(
        body.getWorldPoint(thruster.localPosition),
        thruster.maxForce.length * relativeForce * 1,
        new Vector2(1.0, 1.0),
        new Color3i.fromRGBd(250.0, 0.0, 0.0));
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
    return body
        .getLinearVelocityFromLocalPoint(ORIGIN)
        .sub(target.body.getLinearVelocityFromLocalPoint(ORIGIN));
  }

  /*
   * The angle at which [this] is moving towards/away from [target]. For
   * example, when this ship is aproaching target straight on, the velocity
   * angle would be 180° (pi).
   */
  num getVelocityAngleOf(Box2DShip target) {
    Vector2 relativeVelocityTo = getRelativeVelocityTo(target);
    return Math.acos(relativeVelocityTo.dot(FORWARD) /
            (FORWARD.length * relativeVelocityTo.length)) *
        (relativeVelocityTo.dot(RIGHT) > 0 ? 1 : -1);
  }
}

class AIBox2DShip extends Box2DShip {
  AIBox2DShip(
      ShipCombatSituation situation, num length, num width, Vector2 position,
      {num initialAngle: 0, List thrusters: const []})
      : super(situation, length, width, position,
            thrusters: thrusters, initialAngle: initialAngle) {}

  Box2DShip target;

  /**
   * The current AI mode in charge of the ship. Examples: "steer towards point",
   * "stop", "run away", "face other ship",
   *
   * If [:null:], the ship is in manual mode.
   */
  ShipBrainMode brainMode;
  Map userData = {};

  void applyBrain() {
    if (brainMode != null) {
      _currentPowerConsumption = 0;
      brainMode.control(this, target, situation, userData);
    }
  }

  /**
   * A set of inputs useful for most maneuvers that involve another ship.
   * All inputs are relative (relative speed of [ship] to [target], not absolute
   * speed of [ship] in the environment).
   */
  static List<num> getStandardTargetInputs(Box2DShip ship, Box2DShip target) {
    List<num> inputs = new List<num>(8);

    num angVel = ship.body.angularVelocity;
    inputs[0] = ShipBrainMode.valueToNeuralInput(angVel, 0, 2);
    inputs[1] = ShipBrainMode.valueToNeuralInput(angVel, 0, -2);
    inputs[2] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVectorTo(target).length, 0, 50);
    num angle = ship.getAngleTo(target);
    inputs[3] = ShipBrainMode.valueToNeuralInput(angle, 0, Math.PI * 2);
    inputs[4] = ShipBrainMode.valueToNeuralInput(angle, 0, -Math.PI * 2);
    inputs[5] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVelocityTo(target).length, 0, 5);
    num velocityAngle = ship.getVelocityAngleOf(target);
    inputs[6] = ShipBrainMode.valueToNeuralInput(velocityAngle, 0, Math.PI * 2);
    inputs[7] =
        ShipBrainMode.valueToNeuralInput(velocityAngle, 0, -Math.PI * 2);

    return inputs;
  }
}

class Thruster {
  final Vector2 localPosition;
  final Vector2 maxForce;
  Thruster(num x, num y, num maxForwardThrust, num maxLateralThrust)
      : localPosition = new Vector2(x.toDouble(), y.toDouble()),
        maxForce = new Vector2(
            maxForwardThrust.toDouble(), maxLateralThrust.toDouble());
}
