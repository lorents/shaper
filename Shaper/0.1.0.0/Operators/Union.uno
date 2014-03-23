using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;

namespace Shaper
{
	public class Union : Shape
	{
		public Shape Left { get; private set; }
		public Shape Right { get; private set; }

		public Union(Shape Left, Shape Right)
		{
			this.Left = Left;
			this.Right = Right;
		}
		
		internal override void Draw(DrawContext dc)
		{
			Left.Draw(dc);
			Right.Draw(dc);
		}

	}
}