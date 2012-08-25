# Copyright (c) 2012 CefPython Authors. All rights reserved.
# License: New BSD License.
# Website: http://code.google.com/p/cefpython/

include "imports.pyx"
include "utils.pyx"

NAVTYPE_LINKCLICKED = <int>cef_types.NAVTYPE_LINKCLICKED
NAVTYPE_FORMSUBMITTED = <int>cef_types.NAVTYPE_FORMSUBMITTED
NAVTYPE_BACKFORWARD = <int>cef_types.NAVTYPE_BACKFORWARD
NAVTYPE_RELOAD = <int>cef_types.NAVTYPE_RELOAD
NAVTYPE_FORMRESUBMITTED = <int>cef_types.NAVTYPE_FORMRESUBMITTED
NAVTYPE_OTHER = <int>cef_types.NAVTYPE_OTHER
NAVTYPE_LINKDROPPED = <int>cef_types.NAVTYPE_LINKDROPPED

def InitializeRequestHandler():

	# Callbacks - make sure event names are proper - hard to detect error.
	# Call it in cefpython.pyx > __InitializeClientHandler().
	global __clientHandler
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnBeforeBrowse(<OnBeforeBrowse_type>RequestHandler_OnBeforeBrowse)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnBeforeResourceLoad(<OnBeforeResourceLoad_type>RequestHandler_OnBeforeResourceLoad)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnResourceRedirect(<OnResourceRedirect_type>RequestHandler_OnResourceRedirect)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnResourceResponse(<OnResourceResponse_type>RequestHandler_OnResourceResponse)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_OnProtocolExecution(<OnProtocolExecution_type>RequestHandler_OnProtocolExecution)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_GetDownloadHandler(<GetDownloadHandler_type>RequestHandler_GetDownloadHandler)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_GetAuthCredentials(<GetAuthCredentials_type>RequestHandler_GetAuthCredentials)
	(<ClientHandler*>(__clientHandler.get())).SetCallback_GetCookieManager(<GetCookieManager_type>RequestHandler_GetCookieManager)

cdef cbool RequestHandler_OnBeforeBrowse	(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefFrame] cefFrame,
		CefRefPtr[CefRequest] cefRequest,
		cef_types.cef_handler_navtype_t navType,
		cbool isRedirect
	) except * with gil:

	try:
		return <cbool>False

		# ignoreError=True - when creating browser window there is no browser yet added to the __pyBrowsers,
		# it's happening because CreateBrowser() does the initial navigation.
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser, True)
		if not pyBrowser:
			return <cbool>False
		
		pyFrame = GetPyFrameByCefFrame(cefFrame)
		pyRequest = GetPyRequestByCefRequest(cefRequest)

		handler = pyBrowser.GetClientHandler("OnBeforeBrowse")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			return <cbool>bool(handler(pyBrowser, pyFrame, pyRequest, <int>navType, isRedirect))
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef cbool RequestHandler_OnBeforeResourceLoad(
		CefRefPtr[CefBrowser] cefBrowser,
		CefRefPtr[CefRequest] cefRequest,
		CefString& cefRedirectURL,
		CefRefPtr[CefStreamReader]& cefResourceStream,
		CefRefPtr[CefResponse] cefResponse,
		int loadFlags
	) except * with gil: # "with gil" - removed. CEF calls this function on IO thread, if you try to acquire GIL lock then app hangs up.
	print "OnBeforeResourceLoad"
	try:
		print "try"
		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		print "pyBrowser"
		pyRequest = GetPyRequestByCefRequest(cefRequest)
		print "pyRequest"
		pyRedirectURL = [""]
		pyResourceStream = GetPyStreamReaderByCefStreamReader(cefResourceStream)
		pyResponse = GetPyResponseByCefResponse(cefResponse)
		print "pyResponse"

		handler = pyBrowser.GetClientHandler("OnBeforeResourceLoad")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			ret = handler(pyBrowser, pyRequest, pyRedirectURL, pyResourceStream, pyResponse)
			assert type(pyRedirectURL) == list
			assert type(pyRedirectURL[0]) == str
			if pyRedirectURL[0]:
				PyStringToCefString(pyRedirectURL[0], cefRedirectURL)
			return <cbool>bool(ret)
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef void RequestHandler_OnResourceRedirect(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefOldURL,
		CefString& cefNewURL
	) except * with gil:

	try:
		return

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyOldURL = CefStringToPyString(cefOldURL)
		pyNewURL = [CefStringToPyString(cefNewURL)] # [""] - string by reference by passing in a list

		handler = pyBrowser.GetClientHandler("OnResourceRedirect")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			handler(pyBrowser, pyOldURL, pyNewURL)
			PyStringToCefString(pyNewURL[0], cefNewURL) # we should call it only when pyNewURL[0] changed.
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef void RequestHandler_OnResourceResponse(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		CefRefPtr[CefResponse] cefResponse,
		CefRefPtr[CefContentFilter]& cefFilter
	) except * with gil:

	try:
		return

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyURL = CefStringToPyString(cefURL)
		pyResponse = GetPyResponseByCefResponse(cefResponse)
		pyFilter = None # TODO.

		handler = pyBrowser.GetClientHandler("OnResourceResponse")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			handler(pyBrowser, pyURL, pyResponse, pyFilter)
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef cbool RequestHandler_OnProtocolExecution(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefURL,
		cbool& cefAllowOSExecution
	) except * with gil:

	try:
		return <cbool>False

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyURL = CefStringToPyString(cefURL)
		pyAllowOSExecution = [bool(cefAllowOSExecution)] # [True]

		handler = pyBrowser.GetClientHandler("OnProtocolExecution")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			ret = handler(pyBrowser, pyURL, pyAllowOSExecution)
			cefAllowOSExecution = <cbool>bool(pyAllowOSExecution[0])
			return <cbool>bool(ret)
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef cbool RequestHandler_GetDownloadHandler(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& cefMimeType,
		CefString& cefFilename,
		cef_types.int64 cefContentLength,
		CefRefPtr[CefDownloadHandler]& cefDownloadHandler
	) except * with gil:

	try:
		return <cbool>False

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyMimeType = CefStringToPyString(cefMimeType)
		pyFilename = CefStringToPyString(cefFilename)
		pyContentLength = int(cefContentLength)
		pyDownloadHandler = None # TODO.

		handler = pyBrowser.GetClientHandler("GetDownloadHandler")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			return <cbool>bool(handler(pyBrowser, pyMimeType, pyFilename, pyContentLength, pyDownloadHandler))
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef cbool RequestHandler_GetAuthCredentials(
		CefRefPtr[CefBrowser] cefBrowser,
		cbool cefIsProxy,
		CefString& cefHost,
		int cefPort,
		CefString& cefRealm,
		CefString& cefScheme,
		CefString& cefUsername,
		CefString& cefPassword
	) except * with gil:

	try:
		return <cbool>False

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyIsProxy = bool(cefIsProxy)
		pyHost = CefStringToPyString(cefHost)
		pyPort = int(cefPort)
		pyRealm = CefStringToPyString(cefRealm)
		pyScheme = CefStringToPyString(cefScheme)
		pyUsername = [""]
		pyPassword = [""]

		handler = pyBrowser.GetClientHandler("GetAuthCredentials")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			ret = handler(pyBrowser, pyIsProxy, pyHost, pyPort, pyRealm, pyScheme, pyUsername, pyPassword)
			if ret:
				PyStringToCefString(pyUsername[0], cefUsername)
				PyStringToCefString(pyPassword[0], cefPassword)
			return <cbool>bool(ret)
		else:
			return <cbool>False
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)

cdef CefRefPtr[CefCookieManager] RequestHandler_GetCookieManager(
		CefRefPtr[CefBrowser] cefBrowser,
		CefString& mainURL
	) except * with gil:

	try:
		return <CefRefPtr[CefCookieManager]>NULL

		pyBrowser = GetPyBrowserByCefBrowser(cefBrowser)
		pyMainURL = CefStringToPyString(mainURL)

		handler = pyBrowser.GetClientHandler("GetCookieManager")
		inheritFrames = False
		if type(handler) is tuple:
			handler = handler[0]
		if handler:
			ret = handler(pyBrowser, pyMainURL)
			if ret:
				# TODO: return CefCookieManager.
				pass
			return <CefRefPtr[CefCookieManager]>NULL 
		else:
			return <CefRefPtr[CefCookieManager]>NULL
	except:
		(exc_type, exc_value, exc_trace) = sys.exc_info()
		sys.excepthook(exc_type, exc_value, exc_trace)
