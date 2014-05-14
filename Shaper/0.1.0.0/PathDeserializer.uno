using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;

namespace Shaper
{
	class PathDeserializer
	{
		public static IEnumerable<ControlPoint> Deserialize(string data)
		{
			return new PathDeserializer(data).Deserialize();
		}

		readonly Dictionary<string, Action> _commands = new Dictionary<string, Action>();
		readonly string[] _parts;
		readonly List<ControlPoint> _controlPoints = new List<ControlPoint>();
		float2 _position = float2(0,0);
		float2 _tangent = float2(0,0);
		int i = 0;

		bool NextIsNewCommand
		{
			get { return Contains(_commands.Keys, _parts[i]); }
		}

		bool HasNext
		{
			get { return i < _parts.Length; }
		}
		
		PathDeserializer(string data)
		{
			_parts = ToArray(Where(AsEnumerable(data.Split(' ')), NotEmpty));
			_commands["M"] = MoveTo;
			_commands["C"] = CurveTo;
		}
		
		static bool NotEmpty(string str) { return str != ""; }
		
		public IEnumerable<ControlPoint> Deserialize()
		{
			while (HasNext)
			{
				var currentCommand = ReadString();
				while (HasNext && !NextIsNewCommand)
					_commands[currentCommand]();
			}
			_controlPoints.Add(new ControlPoint() { TangentLeft = _tangent, Position = _position, TangentRight = _position });
			return _controlPoints;
		}

		void CurveTo()
		{
			var x1 = ReadFloat();
			var y1 = ReadFloat();
			var x2 = ReadFloat();
			var y2 = ReadFloat();
			var x = ReadFloat();
			var y = ReadFloat();
			//debug_log "C " + x1 + " " + y1 + " " + x2 + " " + y2 + " " + x + " " + y;
			_controlPoints.Add(new ControlPoint() { TangentLeft = _tangent, Position = _position, TangentRight = float2(x1,y1) });
			_tangent = float2(x2,y2);
			_position = float2(x,y);
		}

		void MoveTo()
		{
			var x = ReadFloat();
			var y = ReadFloat();
			//debug_log "M " + x + " " + y;
			_position = _tangent = float2(x,y);
		}

		float ReadFloat()
		{
			return float.Parse(ReadString());
		}

		string ReadString()
		{
			return _parts[i++];
		}
	}
}