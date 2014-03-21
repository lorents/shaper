using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;

namespace Shaper
{
    public class App : Uno.Application
    {
		Shape _shape;
		
		public App()
		{
			var circle = new Circle(Radius: 50);
			var innerCircle = new Circle(Radius: 40.0f, Position: float2(50,0));//circle.Animate(Position: s => Tan(_time));
			
			_shape = circle.Union(innerCircle);

		}
		
        public override void Draw()
        {
			_shape.Draw();
        }
    }
}