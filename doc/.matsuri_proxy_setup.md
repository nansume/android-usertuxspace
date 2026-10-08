======================================================================
=     Bypass a censura with Matsuri (android,proxy)         =
======================================================================

=====================================================
1)
[MainMenu]
=>[Configuration]
=>[right+menu]
=>[Add Profile]
=>[Manual Settings]
set [ SOCKS | HTTP ]
-----------------------------------------------------
Profile config (for SOCKS,HTTP):
-----------------------------------------------------
Profile Name: <proxy-name>
Server: <ipaddr>
Remote Port: <port>
Username (optional): <user>
Password (optional): <pass>
-----------------------------------------------------

2) choose Profile.

3) For Connected tap to button.
=====================================================

==============================================
4)
[MainMenu]
=>[Settings]
Auto Connect: ON
==============================================


=========================================================
5)
[MainMenu]
=>[Route]
=>in top menu button to <+>
---------------------------------------------------------
Route Settings:
-----------------------------------
Route Name: Some rule for Censura
Applications: <set apps and on>
domain (new line to separate): 
  domain_regex:.*\.some-site1.com
  domain_regex:.*\.some-site2.com
outbound: <my-proxy [Select Profile...] (socks|http|ssh)>
---------------------------------------------------------
<Some rule for Censura>: press the button to: ON
=========================================================

===========================================================================
6) Optional
[MainMenu]
=>[Settings]
---------------------------------------------------------------------------
(Misc Settings)
---------------
Connection Test URL: (replace: <http://> to <https://> - other test Failed)
===========================================================================

===============================================================================================
-----------------------------------------------------------------------------------------------
https://github.com/sysfn339/Matsuri-Android/blob/main/README.md
-----------------------------------------------------------------------------------------------
[Route Rule - sing-box](https://sing-box.sagernet.org/configuration/route/rule/#domain_keyword)
[Free V2ray Configs - list proxy servers](https://github.com/barry-far/V2ray-Configs)
===============================================================================================