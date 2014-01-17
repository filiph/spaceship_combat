part of spaceship_combat;

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
                      new Thruster(-1.5, -0.5, 0, -0.2), // Back maneuverability
                      new Thruster(-1.5,  0.5, 0, 0.2),
                      new Thruster( 1.5, -0.5, 0, -0.2),  // Front maneuverability
                      new Thruster( 1.5,  0.5, 0, 0.2)]);
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
                               Object userData);
  
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
                                     ShipCombatSituation worldState, 
                                     Object userData);

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
      num force = ((outputs[i] + 1) / 2).clamp(0, 1);  // from <-1,1> to <0,1>
      ship.thrust(i, force);
    }
  }
}


int STATUS_UPDATE_FREQ = 10;
int statusUpdateCounter = 0;

final List<SetupFunction> genericSetupFunctions = [
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

class FaceOtherShipMode extends ThrusterControllingShipBrainMode {
  FaceOtherShipMode() : super();
  
  var _bestPhenotypeGenes = null;

  int inputNeuronsCount = 8;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) => AIBox2DShip.getStandardTargetInputs(ship, target);

  List<SetupFunction> setupFunctions = genericSetupFunctions
      ..add((ShipCombatSituation s) {
        print("- back slightly off, target moving");
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2 + 0.1);
        s.ships.last.body.applyLinearImpulse(new Vector2(-0.1, -0.2), new Vector2(0.0, -1.0));
      });
  
  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
                               ShipCombatSituation worldState,
                               Object userData) {
    num angleScore = ship.getAngleTo(target).abs();
    num angularScore = ship.body.angularVelocity.abs();
    num relativeScore = ship.getRelativeVelocityTo(target).length;
    
    num fitness = 
        (10 * angleScore + angularScore + relativeScore);
    
    if (ship.body.contactList != null) {
      fitness += 50000;
    }
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, target, worldState, userData);
      experimentStatusEl.text = """ 
Angle (${ship.getAngleTo(target).toStringAsFixed(2)}) ${angleScore < 0.5 ? "*": ""}
AnguV (${ship.body.angularVelocity.toStringAsFixed(2)})
RelV  (${ship.getRelativeVelocityTo(target).length.toStringAsFixed(2)})
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
  
  var _bestPhenotypeGenes = null;
  
  int inputNeuronsCount = 8;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) => AIBox2DShip.getStandardTargetInputs(ship, target);
  
  List<SetupFunction> setupFunctions = genericSetupFunctions;
  
  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target,
                               ShipCombatSituation worldState,
                               Object userData) {
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
    if (ship.body.contactList != null) {
      (userData as Map)["rammed"] = true;
      var score = ship.body.angularVelocity.abs() * 10;  // prefer straight line
      score += ship.getAngleTo(target).abs() * 100; // prefer head on collision
      return score;
    }

    return 1;
  }
}

class RunAwayMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 8;

  var _bestPhenotypeGenes = null;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) => AIBox2DShip.getStandardTargetInputs(ship, target);
  
  List<SetupFunction> setupFunctions = 
      new List<SetupFunction>.from(genericSetupFunctions)
        ..removeLast()
        ..removeLast()
        ..addAll([
            (ShipCombatSituation s) {
              print("- back with impulse");
              s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
              s.ship.body.applyLinearImpulse(new Vector2(2.0, 0.0), new Vector2(0.0, -1.0));
            },
            (ShipCombatSituation s) {
              print("- front with impulse");
              s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 2);
              s.ship.body.applyLinearImpulse(new Vector2(0.0, 2.0), new Vector2(0.0, -1.0));
            }]); 

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target, 
                               ShipCombatSituation s, Object userData) {
    num velocityScore = 1 / (ship.getRelativeVelocityTo(target).length + 1);
    num proximityScore = 1 / Math.pow((ship.getRelativeVectorTo(target).length + 1) / 100, 2);  // 1 / (x/100)^2
    num angleScore = Math.PI - ship.getAngleTo(target).abs();
    
    num fitness = velocityScore + proximityScore + angleScore;
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, ship.target, ship.situation,
          userData);
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

class DockLeftMode extends ThrusterControllingShipBrainMode {
  int inputNeuronsCount = 8;
  
  var _bestPhenotypeGenes = null;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) => AIBox2DShip.getStandardTargetInputs(ship, target);
  
  List<SetupFunction> setupFunctions = 
      new List<SetupFunction>.from(genericSetupFunctions)
        ..removeLast()
        ..removeLast()
        ..addAll([
            (ShipCombatSituation s) {
              print("- back with impulse");
              s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
              s.ship.body.applyLinearImpulse(new Vector2(2.0, 0.0), new Vector2(0.0, -1.0));
            },
            (ShipCombatSituation s) {
              print("- front with impulse");
              s.ship.body.setTransform(new Vector2(0.0, 0.0), Math.PI / 2);
              s.ship.body.applyLinearImpulse(new Vector2(0.0, 2.0), new Vector2(0.0, -1.0));
        }]); 

  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target, 
                               ShipCombatSituation s, Object userData) {
    num velocityScore = ship.getRelativeVelocityTo(target).length;
    num proximityScore = ship.getRelativeVectorTo(target).length;
    num angle = ship.getAngleTo(target);
    num wantedAngle = - Math.PI / 2;
    num angleScore = (angle - wantedAngle).abs();
    num angVel = ship.body.angularVelocity.abs();
    
    num fitness = velocityScore + 5 * proximityScore + 5 * angleScore + angVel;
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, ship.target, ship.situation,
          userData);
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
    
    if (ship.body.contactList != null) {
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
  
  var _bestPhenotypeGenes = null;
  
  List<num> getInputs(AIBox2DShip ship, Box2DShip target, ShipCombatSituation s,
      Object userData) => AIBox2DShip.getStandardTargetInputs(ship, target);
  
  List<SetupFunction> setupFunctions = [
      (ShipCombatSituation s) {
        // Default
      },
      (ShipCombatSituation s) {
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
        s.ship.body.applyLinearImpulse(new Vector2(2.0, 0.0), new Vector2(0.0, -1.0));
      },
      (ShipCombatSituation s) {
        s.ship.body.setTransform(new Vector2(0.0, 0.0), - Math.PI / 2);
        s.ships.last.body.applyLinearImpulse(new Vector2(0.1, 0.0), s.ships.last.body.position);
      },
      (ShipCombatSituation s) {
        s.ships.last.body.applyLinearImpulse(new Vector2(-0.2, 0.0), s.ships.last.body.position);
      },
  ];
  
  num iterativeFitnessFunction(AIBox2DShip ship, Box2DShip target, 
                               ShipCombatSituation s, Object userData) {
    num velocityScore = ship.getRelativeVelocityTo(target).length;
    num angVel = ship.body.angularVelocity.abs();
    
    num fitness = 10 * velocityScore + angVel;
    
    statusUpdateCounter++;
    if (statusUpdateCounter == STATUS_UPDATE_FREQ) {
      var inputs = ship.brainMode.getInputs(ship, ship.target, ship.situation,
          userData);
      experimentStatusEl.text = """ 
Velo (${velocityScore.toStringAsFixed(2)})
AngV (${(ship.body.angularVelocity).toStringAsFixed(2)})
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

class ShipCombatSituation extends Demo {
  /** Constructs a new BoxTest. */
  ShipCombatSituation({this.fitnessFunction, this.maxTimeToRun: 1000}) 
      : super("Box test", simEl, new Vector2(0.0, 0.0)) {
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
    debugDraw.setCamera(ship.body.position.x * scale + 450, 
        ship.body.position.y * scale + 300, scale);
    
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
    bodyDef.linearDamping = 0.1; // Reality is Unrealistic...
    bodyDef.angularDamping = 0.2; // As above, plus let's count with stabilization jets...
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
    
    situation.debugDraw.drawSolidCircle(body.getWorldPoint(thruster.localPosition), 
        thruster.maxForce.length * relativeForce * 1, 
        new Color3.fromRGB(250, 0, 0));
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
  Map userData = {};
  
  void applyBrain() {
    if (brainMode != null) {
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
    inputs[4] = ShipBrainMode.valueToNeuralInput(angle, 0, - Math.PI * 2);
    inputs[5] = ShipBrainMode.valueToNeuralInput(
        ship.getRelativeVelocityTo(target).length, 0, 5);
    num velocityAngle = ship.getVelocityAngleOf(target);
    inputs[6] = ShipBrainMode.valueToNeuralInput(velocityAngle, 0, Math.PI * 2);
    inputs[7] = 
        ShipBrainMode.valueToNeuralInput(velocityAngle, 0, - Math.PI * 2);
    
    return inputs;
  }
}

class Thruster {
  final Vector2 localPosition;
  final Vector2 maxForce;
  Thruster(num x, num y, num maxForwardThrust, num maxLateralThrust) :
    localPosition = new Vector2(x.toDouble(), y.toDouble()),
    maxForce = 
        new Vector2(maxForwardThrust.toDouble(), maxLateralThrust.toDouble()); 
}
