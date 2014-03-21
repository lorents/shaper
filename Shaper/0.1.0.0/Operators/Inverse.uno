using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;

namespace Shaper
{
	public class Inverse : Shape
	{
		public Shape Of { get; private set; }
		
		public Inverse(Shape Of)
		{
			this.Of = Of;
		}
	}
}