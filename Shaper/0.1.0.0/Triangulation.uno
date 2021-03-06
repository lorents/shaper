using Uno.Collections;
using Uno.Collections.EnumerableExtensions;
using Uno;

// COTD Entry submitted by John W. Ratcliff [jratcliff@verant.com]
// (Ported to Uno)

namespace Shaper
{
	class PolygonTriangulation
	{
		// triangulate a contour/polygon, place resulting indices in result

		public static IEnumerable<ushort> CreateTriangles(IEnumerable<float2> vertices)
		{
			return new PolygonTriangulation(vertices).CreateTriangles();
		}

		readonly float2[] _vertices;
		readonly List<ushort> V;

		PolygonTriangulation(IEnumerable<float2> vertices)
		{
			_vertices = ToArray(vertices);

			var n = _vertices.Length; // TODO: has count
			if (n < 3)
				throw new Exception("contour must include at least 3 vertices");

			// we want a counter-clockwise polygon in V (create indirection table used to pop of done vertices)
			V = new List<ushort>();
			if (CalculateArea() > 0)
				for (ushort v=0; v<n; v++)
					V.Add(v);
			else
				for (ushort v=0; v<n; v++)
					V.Add((ushort)((n-1)-v));
		}

		IEnumerable<ushort> CreateTriangles()
		{
			var result = new List<ushort>();

			// remove nv-2 Vertices, creating 1 triangle every time
			int count = 2*V.Count; // error detection

			for (int m = 0, v = V.Count-1; V.Count > 2; )
			{
				// if we loop, it is probably a non-simple polygon
				if ((count--) <= 0)
					throw new Exception("ERROR - probable bad polygon!");

				// three consecutive vertices in current polygon, <u,v,w>
				int u = v; // previous
				if (u >= V.Count) u = 0;

				v = u+1; // new v
				if (v >= V.Count) v = 0;

				int w = v+1; // next
				if (w >= V.Count) w = 0;

				if (Snip(u,v,w))
				{
					// output Triangle
					result.Add(V[u]);
					result.Add(V[v]);
					result.Add(V[w]);
					m++;

					// remove v from remaining polygon
					V.RemoveAt(v);

					// resest error detection counter
					count = 2*V.Count;
				}
			}
			return result;
		}

		// compute area of a contour/polygon
		float CalculateArea()
		{
			int n = _vertices.Length;

			float A = 0.0f;
			for(int p = n-1, q = 0; q < n; p = q++)
			{
				A += _vertices[p].X * _vertices[q].Y - _vertices[q].X * _vertices[p].Y;
			}
			return A*0.5f;
		}

		// return true if triangle uvw does not contain any other points
		bool Snip(int u, int v, int w)
		{
			var n = V.Count;
			var A = _vertices[V[u]];
			var B = _vertices[V[v]];
			var C = _vertices[V[w]];

			if (float.ZeroTolerance > (((B.X-A.X)*(C.Y-A.Y)) - ((B.Y-A.Y)*(C.X-A.X))))
				return false;

			for (var p=0; p<n; p++)
			{
				if ((p == u) || (p == v) || (p == w))
					continue;

				var P = _vertices[V[p]];
				if (InsideTriangle(A.X, A.Y, B.X, B.Y, C.X, C.Y, P.X, P.Y))
					return false;
			}

			return true;
		}

		static bool InsideTriangle(float AX, float AY, float BX, float BY, float CX, float CY, float PX, float PY)
		{
			var ax = CX - BX; var ay = CY - BY;
			var bx = AX - CX; var by = AY - CY;
			var cx = BX - AX; var cy = BY - AY;
			var apx = PX - AX; var apy = PY - AY;
			var bpx = PX - BX; var bpy = PY - BY;
			var cpx = PX - CX; var cpy = PY - CY;
			var aCROSSbp = ax*bpy - ay*bpx;
			if (aCROSSbp < 0.0f) return false;
			var cCROSSap = cx*apy - cy*apx;
			if (cCROSSap < 0.0f) return false;
			var bCROSScp = bx*cpy - by*cpx;
			if (bCROSScp < 0.0f) return false;
			return true;
		}
	}
}