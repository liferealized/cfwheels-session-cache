<cfcomponent output="false" mixin="controller,model,application">

	<cffunction name="init" access="public" output="false">
		<cfscript>
			if (StructKeyExists(application, "sessionFacade"))
				StructDelete(application, "sessionFacade");
				
			this.version = "1.0,1.1";
		</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="sessionCache" access="public" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="value" required="false" type="any" />
		<cfscript>
			// set the session facade class to the application scope so we are not recreating the object for every request
			$ensureSessionFacadeExists();	
			if (StructKeyExists(arguments, "value"))
			{
				application.sessionFacade.set(arguments.key, arguments.value);
				return;
			}
		</cfscript>
		<cfreturn application.sessionFacade.get(arguments.key) />
	</cffunction>
	
	<cffunction name="sessionKeyExists" returntype="boolean" access="public" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfset $ensureSessionFacadeExists() />
		<cfreturn application.sessionFacade.exists(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="sessionDelete" access="public" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfset $ensureSessionFacadeExists() />
		<cfreturn application.sessionFacade.delete(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="$ensureSessionFacadeExists" access="public" output="false" returntype="void">
		<cfscript>
			if (not StructKeyExists(application, "sessionFacade"))
				application.sessionFacade = CreateObject("component", "SessionFacade").init();		
		</cfscript>
	</cffunction>

</cfcomponent>