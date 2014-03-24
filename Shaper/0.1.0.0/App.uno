using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;
using Uno.Collections.EnumerableExtensions;

namespace Shaper
{
    public class App : Uno.Application
    {
        public override void Draw()
        {
			//_shape.Draw();

			var f = (float)Sin(FrameTime) ;
			var f2 = (float)Cos(FrameTime*0.5f);
			var f3 = (float)Sin(FrameTime*2.9f);

			var p = float2(0,Math.Abs(f2))*100.0f;
			var s = float2(1-f*0.5f+0.8f,f*0.5f+0.8f);


			var circle = new Circle(Scale: s, Radius: 100.0f, Position: p)
				.Union(new Circle());

			circle.Draw();
        }
    }
}