using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;

namespace Shaper
{
	class PathSerializer
	{
		public static string Serialize(IEnumerable<ControlPoint> points)
		{
			var data = "";

			var ps = ToArray(points);
			if (ps.Length == 0) return null;

			data += "M " + ps[0].Position.X + " " + ps[0].Position.Y + " ";
			for (int i =0; i<ps.Length -1; i++)
			{
				var a = ps[i];
				var b = ps[i+1];
				data += "C " + a.TangentRight.X + " " + a.TangentRight.Y + " " + b.TangentLeft.X + " " + b.TangentLeft.Y + " " + b.Position.X + " " + b.Position.Y + " ";
			}
			return data;
		}
	}
}