import 'dart:html';
import 'dart:svg';
import 'dart:async';
import 'package:box2d/box2d_browser.dart';
import 'dart:math' as Math;
import 'package:backy/backy.dart';

void main() {
//  DivElement el = querySelector("#sample_container_id");
  runExperiment();
}

final int maxGenerations = 10;
int currentGeneration = 0;
final int maxExperiments = 30;
int currentExperiment = 0;
final int winners = 10;
List records = new List<ExperimentRecord>();

void runExperiment({List<List<Weight>> predefinedBrains}) {
  List<Weight> weights;
  if (predefinedBrains == null || predefinedBrains.isEmpty) {
    weights = null;
  } else {
    weights = predefinedBrains.removeAt(0);
  }
  new ShipCombatSituation(scoreOutcomeFunction: scorePutOnNose, precursorWeights: weights).runTest()
    .then((ShipCombatSituation s) {
      num score = scorePutOnNose(s);
      print("Score: $score");
      print("Angular Velocity: ${s.bodega.body.angularVelocity}");
      num lengthsProduct = 1 * s.bodega.relativeVectorToTarget.length;
      print("Dot Product: ${s.bodega.relativeVectorToTarget.dot(new Vector2(1.0, 0.0)) / lengthsProduct}");
      
      records.add(new ExperimentRecord(s.bodega.brain.getWeights(), score, s.currentTime));
      
      s.destroy();
      
      currentExperiment++;
      if (currentExperiment < maxExperiments) {
        runExperiment(predefinedBrains: predefinedBrains);
      } else {
        currentGeneration++;
        if (currentGeneration < maxGenerations) {
          print("=== GENERATION ${currentGeneration}");
          runNewGeneration();
        }
      }
  });
}

void runNewGeneration() {
  records.sort((ExperimentRecord a, ExperimentRecord b) => b.finalScore - a.finalScore);
  records.forEach(print);
  records.getRange(0, winners).forEach((ExperimentRecord record) {
    
  });
}

void _modifyWeightsFromSource(List<Weight> weights, List<Weight> source, num maxDelta) {
  int len = weights.length;
  List<Weight> newWeights = new List<Weight>(len);
  for (int i = 0; i < len; i++) {
    Weight orig = weights[i];
    newWeights[i] = new Weight(orig.width, orig.height, orig.neuron, 0, orig.backy);
  }
}

class ExperimentRecord {
  num finalScore;
  num timeToAchieve;
  List<Weight> weights;
  ExperimentRecord(this.weights, this.finalScore, this.timeToAchieve);
  String toString() {
    return "Experiment: score = $finalScore, timeToAchieve = $timeToAchieve\n"
        "$weights\n\n";
  }
}

num scorePutOnNose(ShipCombatSituation s) {
  if (s.world.contactCount > 0) {
    return double.NEGATIVE_INFINITY;  // Autofail.
  }
  num lengthsProduct = 1 * s.bodega.relativeVectorToTarget.length;
  num dotproduct = s.bodega.relativeVectorToTarget.dot(new Vector2(1.0, 0.0)) / lengthsProduct;
  num dotScore = dotproduct < 0 ? 0 : dotproduct * dotproduct;
  
  num angularVelocity = s.bodega.body.angularVelocity;
  num angularScore = (1 - angularVelocity.abs()).clamp(0, 1);
  
  num relativeScore = (1 - (s.bodega.relativeVelocityToTarget.length / 10)).clamp(0, 1);
  
  num score = (2 * dotScore + angularScore + relativeScore) / 4;
//  print(score);
  return score; 
}

typedef num ScoreOutcomeFunction(ShipCombatSituation situation);

class ShipCombatSituation extends Demo {
  /** Constructs a new BoxTest. */
  ShipCombatSituation({this.scoreOutcomeFunction, this.successThreshold: 1.0, this.maxTimeToRun: 1000,
      this.precursorWeights}) : super("Box test", new Vector2(0.0, 0.0)) {
    
  }
  
  /**
   * Parent's weights.
   */
  List<Weight> precursorWeights;
  
  num maxTimeToRun;
  num currentTime = 0;
  
  ScoreOutcomeFunction scoreOutcomeFunction;
  num successThreshold;

  Completer<ShipCombatSituation> _completer = new Completer<ShipCombatSituation>();
  
  Future runTest() {
    initialize();
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
      if (score >= successThreshold || score == double.NEGATIVE_INFINITY) {
        _completer.complete(this);
        return false;
      }
    }
    return true; // continue
  }

  void initialize() {
    assert (null != world);
    //_createGround();
    bodega = new AIBox2DShip(this, 1.0, 3.0, new Vector2(0.0, 5.0),
        initialAngle: new Math.Random().nextBool() ? 0 : Math.PI,
        thrusters: [new Thruster(-1.5, -0.5, 1, 0),
                    new Thruster(-1.5,  0.5, 1, 0),
                    new Thruster( 1.5, -0.5, 0.1, 0.2),
                    new Thruster( 1.5,  0.5, 0.1, -0.2)]);
    // Add to list
    bodies.add(bodega.body);
    
    messenger = new Box2DShip(this, 0.3, 0.5, new Vector2(0.0, 15.0));
    // Add to list
    bodies.add(messenger.body);
    
    bodega.target = messenger;
    
    if (precursorWeights != null) {
      bodega.brain.setWeights(precursorWeights);
    }
    
//    print(bodega.brain.weights.first.weights);
//    var trainer = new Trainer(backy: bodega.brain, maximumReapeatingCycle: 2000, precision: .1);
//    trainer.addTrainingCase(bodega.getInputs(), [0,0,0,1]);
//    print(trainer.trainOnlineSets());
//    print(bodega.brain.weights.first.weights);
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
    neuron.bias = 2;
    brain = new Backy([getInputs().length, getInputs().length - 1, thrusters.length], neuron);
  }
  
  Box2DShip target;
  Backy brain;
  
  Vector2 get relativeVectorToTarget => body.getLocalVector2(target.body.position);
  Vector2 get relativeVelocityToTarget => 
      body.getLinearVelocityFromLocalPoint(new Vector2(0.0, 0.0)).sub(target.body.getLinearVelocityFromLocalPoint(new Vector2(0.0, 0.0)));
  
  List<num> getInputs() {
    List<num> inputs = new List();
    inputs.add(body.angularVelocity);
    if (target == null) {
      inputs.addAll([-1,0,0,0,0]);
    } else {
      inputs.add(1); // Has target.
      num lengthsProduct = 1 * relativeVectorToTarget.length;
      inputs.add((relativeVectorToTarget.length / 50).clamp(0, 2) - 1);
      inputs.add(relativeVectorToTarget.dot(new Vector2(1.0, 0.0)) / lengthsProduct);
      inputs.add(relativeVectorToTarget.dot(new Vector2(0.0, 1.0)) / lengthsProduct);
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