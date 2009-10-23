//
//  PivotQueryTester
//
//  Created by Ketan Anjaria on 2007-10-22.
//  Copyright (c) 2007 kidBombay. All rights reserved.
//
package com.metaweb {
	import flash.display.*	
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import com.metaweb.*;
	import com.metaweb.query.*;
	
	public class PivotQueryTester extends MovieClip {	
		/**
		 * Creates a new PivotQueryTester MovieClip instance.
		 * com.metaweb.PivotQueryTester
		 */
		private var $pivotQuery:PivotQuery;
		public function PivotQueryTester() { 
			super();
			$pivotQuery = new PivotQuery();
			$pivotQuery.addEventListener("search", onGetSearch, false, 0, true);
			$pivotQuery.addPropertyQuery("Founded By","Person","/business/company/founders")
			$pivotQuery.addPropertyQuery("Acquired","Company","/business/company/subsidiary_companies")
			$pivotQuery.addPropertyQuery("Acquired By","Company","/business/company/parent_company")
			$pivotQuery.addPropertyQuery("Founded","Company","/business/company_founder/companies_founded")
			
			$pivotQuery.addPropertyQuery(	"Employee",
																		"Person",
																		"/business/employer/employees",
																		'{"target:/business/employment_tenure/person":[{}]}',
																		'{"to":{"optional":"forbidden","value":null},"title":null}')
																		
			$pivotQuery.addPropertyQuery(	"Past Employee",
																		"Person",
																		"/business/employer/employees",
																		'{"target:/business/employment_tenure/person":[{}]}',
																		'{"to":{"optional":"required","value":null},"title":null}')
			
			$pivotQuery.addPropertyQuery(	"Board Seat",
																		"Person",
																		"/business/board_member/board_memberships",
																		'{"target:company":[{}]}',
																		'{"to":{"optional":"forbidden","value":null},"title":null}')

			$pivotQuery.addPropertyQuery(	"Past Board Seat",
																		"Person",
																		"/business/board_member/board_memberships",
																		'{"target:company":[{}]}',
																		'{"to":{"optional":"required","value":null},"title":null}')		
					
			$pivotQuery.addPropertyQuery(	"Board Member",
																		"Company",
																		"/business/company/board_members",
																		'{"target:member":[{}]}',
																		'{"to":{"optional":"forbidden","value":null},"title":null}')

			$pivotQuery.addPropertyQuery(	"Past Board Member",
																		"Company",
																		"/business/company/board_members",
																		'{"target:member":[{}]}',
																		'{"to":{"optional":"required","value":null},"title":null}')
																																																														
			$pivotQuery.addPropertyQuery(	"Employer",
																		"Company",
																		"/people/person/employment_history",
																		'{"target:/business/employment_tenure/company":[{}]}',
																		'{"to":{"optional":"forbidden","value":null},"title":null}')
																																				
			$pivotQuery.addPropertyQuery(	"Past Employer",
																		"Company",
																		"/people/person/employment_history",
																		'{"target:/business/employment_tenure/company":[{}]}',
																		'{"to":{"optional":"required","value":null},"title":null}')

			$pivotQuery.addPropertyQuery(	"Investment",
																		"Company",
																		"/venture_capital/venture_investor/investments",
																		'{"target:/venture_capital/venture_investment/company":[{}]}',
																		'{"investment_round":null}')
			
			$pivotQuery.addPropertyQuery(	"Investor",
																		"Venture Investor",
																		"/venture_capital/venture_funded_company/venture_investors",
																		'{"target:/venture_capital/venture_investment/investor":[{}]}',
																		'{"investment_round":null}')
																																	
																																																									
			//$pivotQuery.searchByName("Danny Hillis");
			//$pivotQuery.searchByName("Yahoo!");
			$pivotQuery.searchByID('/topic/en/danny_hillis')
			
		}
		private function onGetSearch (p_event:Event):void{
			trace("onGetSearch = " + p_event);
		}
	}
}
