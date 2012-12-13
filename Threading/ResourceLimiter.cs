	using System;
	using System.Collections.Generic;
	using System.Threading;

	public class Limiter
	{
		/// <summary>Use it through the CurrentInstance property</summary>
		private Limiter()
		{}
		
		public static readonly  Limiter CurrentInstance = new Limiter();

		private readonly Dictionary<string, Resource> _resources = new Dictionary<string, Resource>();

		public void AddResource(string resourceName, int maximumInstances)
		{
			const int TimeToPerformOver1000TryEnterInMilliseconds = 100;
			AddResource(resourceName, maximumInstances, new TimeSpan(0, 0, 0, 0, TimeToPerformOver1000TryEnterInMilliseconds));
		}

		private void AddResource(string resourceName, int maximumInstances, TimeSpan maximumTimeToWaitOnAquireLock)
		{
			if (null == resourceName)
				throw new ArgumentNullException();
			if (_resources.ContainsKey(resourceName))
				throw new ArgumentException();
			_resources.Add(resourceName, new Resource(maximumInstances, maximumTimeToWaitOnAquireLock));
		}

		public bool TryUseResource(string resourceName)
		{
			return GetResource(resourceName).TryUseResource();
		}

		public void ReleaseResource(string resourceName)
		{
			GetResource(resourceName).ReleaseResource();
		}

		public int GetLoadingLevel(string resourceName)
		{
			return GetResource(resourceName).LoadingLevel;
		}

		public int GetLoadingThreshold(string resourceName)
		{
			return GetResource(resourceName).LoadingThreshold;
		}

		private Resource GetResource(string resourceName)
		{
			if (null == resourceName)
				throw new ArgumentNullException();
			Resource resource;
			if (_resources.TryGetValue(resourceName, out resource))
				return resource;
			else
				throw new ArgumentOutOfRangeException();
		}


		/// <summary>For usage this instance must be static</summary>
		private class Resource
		{
			public Resource(int maximumItems, TimeSpan maximumTimeToAquireLock)
			{
				if (null == maximumTimeToAquireLock)
					throw new ArgumentNullException();
				if (0 >= maximumItems || 0 >= maximumTimeToAquireLock.TotalMilliseconds)
					throw new ArgumentOutOfRangeException();

				_maximumItems = maximumItems;
				_maximumTimeToAquireLock = maximumTimeToAquireLock;
			}

			readonly object _locker = new object();
			readonly int _maximumItems;
			readonly TimeSpan _maximumTimeToAquireLock;
			int _currentLevel = 0;

			public bool TryUseResource()
			{
				bool lockAquired;

				lockAquired = Monitor.TryEnter(_locker, _maximumTimeToAquireLock);
				if (lockAquired)
				{
					try
					{
						if (_currentLevel < _maximumItems)
						{
							++_currentLevel;
							return true;
						}
						else
							return false;
					}
					finally
					{
						Monitor.Exit(_locker);
					}
				}
				return false;
			}

			public void ReleaseResource()
			{
				Monitor.Enter(_locker);
				try { --_currentLevel; } finally { Monitor.Exit(_locker); }
			}

			public int LoadingLevel
			{
				get
				{
					int loadingLevel = _currentLevel;
					return _currentLevel;
				}
			}

			public int LoadingThreshold
			{
				get { return _maximumItems; }
			}
		}
	}