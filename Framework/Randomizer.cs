using System;
using System.Collections.Generic;
using System.Linq;

namespace SASFleet.Common
{
	public static class Randomizer
	{
		public static IEnumerable<T> GetRandomSubset<T>(this IEnumerable<T> source, int count)
		{
			var set = new HashSet<T>(source);
			if (count > set.Count || 0 > count)
				throw new ArgumentOutOfRangeException();
			Random randomizer = GetRandomizer();
			return set.GetRandomSubset(randomizer, count);
		}

		public static IEnumerable<T> GetRandomSizedSubset<T>(this IEnumerable<T> source)
		{
			Random randomizer = GetRandomizer();
			var set = new HashSet<T>(source);
			int count = randomizer.Next(0, set.Count);
			return set.GetRandomSubset(randomizer, count);
		}

		private static IEnumerable<T> GetRandomSubset<T>(this HashSet<T> source, Random randomizer, int count)
		{
			var set = source.ToArray();
			var picked = new HashSet<int>();
			while (picked.Count < count)
			{
				picked.Add(randomizer.Next(0, set.Length));
			}
			return picked.Select(i => set[i]);
		}

		private static Random GetRandomizer()
		{
			return new Random((int)(DateTime.Now.Ticks % 100000));
		}
	}
}
