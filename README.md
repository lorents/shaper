Shaper
======

Toy 2D/3D shape processing library for Uno


Excample:
---------

    var circle = new Circle(Radius: 50.0f);
    var innerCircle = new Circle(Radius: circle, CalcPosition: i => _time)
    var outline = circle.Outline(Radius: 5.0f);
    
    var fullShape = outline.Fill(color) + circle.Fill(innerCircle.Fill(color));
    
    ...
    fullShape.Draw();

