Shaper
======

Toy 2D/3D shape processing library for Uno

Buzzwords
---------

- Use logic operators to create complex 2D shapes out of primitives
- Fill any shape with color, texture, another shape, or even a totally custom shader
- Animate shapes with a functional reactive approach
- A nomadic API makes programming a breeze, while still maintaining an immutable object graph  

Example
-------
```csharp
var circle = new Circle(Radius: 50);
var innerCircle = circle.Animate(Position: s => _time);
var outline = circle.Outline(Radius: 5);

var color = float4(1,0.2f,0,1);

_fullShape = outline.Union(circle.Intersect(innerCircle)).Fill(color);

// maybe even:
//_fullShape = (outline + circle ^ innerCircle).Fill(color);

...
_fullShape.Draw();
```

Licence
-------

Something free
