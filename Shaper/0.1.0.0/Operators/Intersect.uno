using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;

namespace Shaper
{
	public class Intersect : Shape
	{
		public Shape Left { get; private set; }
		public Shape Right { get; private set; }

		public Intersect(Shape Left, Shape Right)
		{
			this.Left = Left;
			this.Right = Right;
		}

		internal override void Draw(DrawContext dc, double time)
		{

		}
	}
}