/* 
 * Unity - Communities
 * 
 * Community is critical to the student experience--but building community is 
 * just plain hard. Built on Communities and designed specifically for higher ed, 
 * Unity is a powerful networking tool to help you generate engagement and 
 * connect your campus.
 * 
 * Copyright (C) 2015 Motivis Learning Systems Inc.
 * 
 * This program is free software: you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 * To contact Motivis Learning Systems Inc.
 * 25 Pelham Road
 * Salem, NH 03790
 * unity@motivislearning.com
 */

public with sharing class CommunityMenuController {

	private static Boolean currentPage(String urlToCompare) {
		String currentPageName = ApexPages.currentPage().getUrl().replace('/apex','');
		urlToCompare = urlToCompare.replace('/apex','');
		String pp = CommunityUtils.getPackagePrefix();
		if (String.isNotBlank(pp)) {
			urlToCompare = urlToCompare.replace(pp, '');
			currentPageName = currentPageName.replace(pp, '');
		}
		return currentPageName.containsIgnoreCase(urlToCompare);
	}

	public static String getRegistration() {
		String result = 'false';
		if (!currentPage(Page.CommunityRegTerms.getUrl()) && !currentPage(Page.Community404.getUrl())) {
			CommunityRegTermsController crtc = new CommunityRegTermsController();
			result = crtc.checkAndPrepareMenu();
		}
		return result;
	}
	
	public static Boolean getShowHideMenu() {
		Community_Template_Settings__c cts = Community_Template_Settings__c.getOrgDefaults();
		If((String.isBlank(cts.Header_Logo_ImageID__c)) && getIsRegTermsPage()) return false;
		else return true;
	}
	

	public static Boolean getIsRegTermsPage() {
		return currentPage(Page.CommunityRegTerms.getUrl());
	}

	public PageReference getRedirectToLogin() {
		PageReference pr;
		if (UserInfo.getUserType() == 'Guest') {
			pr = Network.forwardToAuthPage(NULL);
			
		}
		return pr;
	}

	public String getAlert() {
		DateTime Now = DateTime.now();
		if (!SObjectType.Community_News__c.isAccessible()) CommunityAccess.ThrowAccessException(SObjectType.Community_News__c);
		List<Community_News__c> newsList = [
			SELECT Id, Name, Teaser__c
			FROM Community_News__c
			WHERE Alert__c = true AND Status__c != 'Pending'
			AND Entry_Date__c <= :Now AND Expiration_Date__c >= :Now
			LIMIT 1
		];
		return newsList.isEmpty() ? '' : newsList[0].Teaser__c;
	}

	public String getHelpLink() {
		if (!SObjectType.Community_Resource__c.isAccessible()) CommunityAccess.ThrowAccessException(SObjectType.Community_Resource__c);
		List<Community_Resource__c> helpList = [SELECT Id, Link__c FROM Community_Resource__c WHERE Status__c = 'Active' AND Help_Link__c = true AND Link__c != NULL];
		return (helpList.size() > 0 && String.isNotBlank(helpList[0].Link__c)) ? helpList[0].Link__c : NULL;
	}

	// -- variables -- lists for wrapper class --
	public static List<LinkItem> LinkItems {
		get {
			List<LinkItem> temp = new List<LinkItem>();

			if (!SObjectType.Community_Resource__c.isAccessible()) CommunityAccess.ThrowAccessException(SObjectType.Community_Resource__c);
			List<Community_Resource__c>  tmp = [
				SELECT Name, Link__c, Sort__c
				FROM Community_Resource__c 
				WHERE Quick_Link__c = TRUE AND Link__c != NULL AND Status__c = 'Active'
				ORDER BY Sort__c, Name
			];
			// As each CommunityResource__c is processed we create a new LinkItem object and add it to the LinkItems
			for (Community_Resource__c cr : tmp) {
				temp.add(new LinkItem(cr.Name, cr.Link__c));
			}

			return temp;
		}
	}
	
	// -- Wrapper class --
	public class LinkItem {
		public String Name {get; set;}
		public String Link {get; set;}

		public LinkItem(String Name, String Link) {
			this.Name = Name;
			this.Link = Link;
		} 
	}
}