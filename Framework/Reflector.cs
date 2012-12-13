using System;
using System.Linq.Expressions;
using System.Reflection;
	public static class Reflector
	{
		public static string GetName<TSource, TProperty>(this TSource source, Expression<Func<TSource, TProperty>> propertyProjection)
			where TSource : class
		{
			return GetPropertyInfo<TSource, TProperty>(source, propertyProjection).Name;
		}

		public static PropertyInfo GetPropertyInfo<TSource, TProperty>(this TSource source, Expression<Func<TSource, TProperty>> propertyProjectionExpression)
			where TSource : class
		{
			Type type = typeof(TSource);
			MemberExpression member = propertyProjectionExpression.Body as MemberExpression;
			if (null == member)
				throw new ArgumentException(string.Format("Expression '{0}' refers to a method, not a property.", propertyProjectionExpression.ToString()));

			PropertyInfo propertyInfo = member.Member as PropertyInfo;
			if (null == propertyInfo)
				throw new ArgumentException(string.Format("Expression '{0}' refers to a field, not a property.", propertyProjectionExpression.ToString()));

			if (type != propertyInfo.ReflectedType && !type.IsSubclassOf(propertyInfo.ReflectedType))
				throw new ArgumentException(string.Format("Expresion '{0}' refers to a property that is not from type {1}.", propertyProjectionExpression.ToString(), type));

			return propertyInfo;
		}
	}