<cfcomponent output="false">

	<cfset request.session = {} />

	<cffunction name="init" access="public">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getCache" access="public">
		<cfreturn request.session />
	</cffunction>
	
	<!--- gets a variable name from the sesssion store --->
	<cffunction name="get" access="public">
		<cfargument name="variableName" required="true" type="string" />
		<cfargument name="errorOnNotFound" required="false" type="boolean" default="false" />
		
		<cfset var loc = {} />
		<Cfset loc.null = "" />
		
		<!--- check to see if we have cached the variables so we do not have to lock the session --->
		<cfif StructKeyExists(request.session, arguments.variableName)>
			<cfreturn StructFind(session, arguments.variableName) />
		</cfif>
		
		<!--- we didn't find it in the cache so try to get it from the session --->
		<cflock scope="session" timeout="30">
			<cfif StructKeyExists(session, arguments.variableName)>
				<cfset loc.value = StructFind(session, arguments.variableName) />
				<cfset loc.dump = StructInsert(request.session, arguments.variableName, loc.value, false) />
				<cfreturn loc.value />
			</cfif>
		</cflock>
		
		<!--- we didn't find it in the session, should we throw an error --->
		<cfif arguments.errorOnNotFound>
			<cfthrow type="reservoir.sessionVariableNotFound"
					 message="The variable #arguments.variableName# could not be found in the session" />
		</cfif>
		
		<cfreturn loc.null />
	</cffunction>
	
	<!--- sets a session variable and caches it in case of a later request --->
	<cffunction name="set">
		<cfargument name="variableName" required="true" type="string" />
		<cfargument name="value" required="true" type="any" />
		<cfargument name="allowOverwrite" required="false" type="boolean" default="true" />
		
		<cfset var loc = {} />
		
		<cfset loc.dump = StructInsert(request.session, arguments.variableName, arguments.value, arguments.allowOverwrite) />
		
		<cflock scope="session" timeout="30">
			<cfset loc.dump = StructInsert(session, arguments.variableName, arguments.value, arguments.allowOverwrite) />
		</cflock>
	</cffunction>
	
	<!--- if we try to get a variable out of the session by calling session.siteId(), 
		  method missing will allow us to do this by recovering from the error --->
	<cffunction name="OnMissingMethod">
		<cfargument name="MissingMethodName" type="string" required="true" />
		<cfargument name="MissingMethodArguments" type="struct" required="true" />
		
		<cfreturn this.get(arguments.MissingMethodName) />	
	</cffunction>

</cfcomponent>