Shaper
======

Toy 2D/3D shape processing library for Uno

Buzzwords
---------

- Use logic operators to create complex 2D shapes out of primitives
- Fill any shape with color, texture, or even a totally custom shader
- Animate shapes with a functional reactive approach
- A nomadic API makes programming a breeze, while still maintaining an immutable object graph
- Constructing shapes using the Node editor will also be possible (when constructor arguments is supported)

Example
-------
```csharp
var circle = new Circle(Radius: 50);
var animatedInnerCircle = circle.Animate(Position: s => Tan(_time));
var outline = circle.Outline(Radius: 5);

var color = float4(1, 0.2f, 0, 1);

_fullShape = outline.Union(circle.Intersect(animatedInnerCircle)).Fill(color);

// maybe even:
//_fullShape = (outline + circle ^ animatedInnerCircle).Fill(color);

...
_fullShape.Draw();
```

Roadmap
-------

Currently nothing is implemented :)

The plan is to first implement a simple subset of the final API with only circles as primitives, and later add support for general vector shapes and more operations. Constructing shapes from text should also be possible at some point in the future, and extruding shapes into 3D solids would be a cool feature.

Licence
-------

Something free
