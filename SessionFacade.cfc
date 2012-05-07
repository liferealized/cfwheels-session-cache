<cfcomponent output="false">

	<cfset request.session = {} />

	<cffunction name="init" access="public" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getCache" access="public" output="false">
		<cfscript>
			if (not StructKeyExists(request, "session"))
				return StructNew();
		</cfscript>
		<cfreturn request.session />
	</cffunction>
	
	<!--- gets a variable name from the sesssion store --->
	<cffunction name="get" access="public" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="errorOnNotFound" required="false" type="boolean" default="false" />
		<cfscript>
			var loc = {};
			
			if (not StructKeyExists(request, "session"))
				request.session = {};
			
			// check to see if we have cached the variables so we do not have to lock the session
			if (StructKeyExists(request.session, arguments.key))
				return StructFind(request.session, arguments.key);
		</cfscript>
		
		<!--- we didn't find it in the cache so try to get it from the session --->
		<cflock name="sessionFacade" type="readonly" timeout="5">
			<cfscript>
				if (StructKeyExists(session, arguments.key))
				{
					loc.value = StructFind(session, arguments.key);
					StructInsert(request.session, arguments.key, loc.value, false);
				}
			</cfscript>
		</cflock>
		
		<cfscript>
			if (StructKeyExists(loc, "value"))
				return loc.value;
				
			if (arguments.errorOnNotFound)
				$throw(type="reservoir.sessionVariableNotFound", message="The variable #arguments.key# could not be found in the session");	
		</cfscript>
		<cfreturn />
	</cffunction>
	
	<!--- sets a session variable and caches it in case of a later request --->
	<cffunction name="set" access="public" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="value" required="true" type="any" />
		<cfargument name="allowOverwrite" required="false" type="boolean" default="true" />
		<cfscript>
			var loc = {};
			
			if (not StructKeyExists(request, "session"))
				request.session = {};
			
			StructInsert(request.session, arguments.key, arguments.value, arguments.allowOverwrite);
		</cfscript>
		
		<cflock name="sessionFacade" type="exclusive" timeout="5">
			<cfset StructInsert(session, arguments.key, arguments.value, arguments.allowOverwrite) />
		</cflock>
	</cffunction>
	
	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="key" required="true" type="string" />
		<cfscript>
			var exists = false;
			
			// check in the cache first
			exists = StructKeyExists(request.session, arguments.key);
		</cfscript>
		<cfif not exists>
			<cflock name="sessionFacade" type="readonly" timeout="5">
				<cfscript>
					exists = StructKeyExists(session, arguments.key);
				</cfscript>
			</cflock>
		</cfif>
		<cfreturn exists />
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="key" required="true" type="string" />
		<cfscript>
			var exists = false;
			
			// check in the cache first
			StructDelete(request.session, arguments.key);
		</cfscript>
		<cfif not exists>
			<cflock name="sessionFacade" type="exclusive" timeout="5">
				<cfscript>
					StructDelete(session, arguments.key);
				</cfscript>
			</cflock>
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- if we try to get a variable out of the session by calling session.siteId(), 
		  method missing will allow us to do this by recovering from the error --->
	<cffunction name="onMissingMethod" access="public" output="false">
		<cfargument name="missingMethodName" type="string" required="true" />
		<cfargument name="missingMethodArguments" type="struct" required="true" />
		
		<cfreturn this.get(arguments.MissingMethodName) />	
	</cffunction>

</cfcomponent>
