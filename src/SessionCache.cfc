<cfcomponent output="false">

	<cffunction name="init" access="public">
		<cfset this.version = "0.9.4">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="sessionCache" access="public">
		<cfargument name="variableName" required="true" type="string" />
		<cfargument name="value" required="false" type="any" />
		
		<cfif not StructKeyExists(variables, "instance")>
			<cfset variables.instance = {} />
		</cfif>
		
		<!--- we need to created our cache on every request --->
		<cfif not StructKeyExists(variables.instance, "sessionFacade")>
			<cfset variables.instance.sessionFacade = createObject("component", "SessionFacade") />
		</cfif>
		
		<cfif StructKeyExists(arguments, "value")>
			<cfset variables.instance.sessionFacade.set(arguments.variableName, arguments.value, true) />
			<cfreturn />
		</cfif>
		
		<cfreturn variables.instance.sessionFacade.get(arguments.variableName) />
	</cffunction>

</cfcomponent>