/*===============================================================================;
;	MoneyMod - A basic AMXmodX plugin for adding a money system based off kills  ;
;	Copyright (C) 2018  Brian Baker https://github.com/Fooly-Cooly               ;
;	Licensed with GPL v3 https://www.gnu.org/licenses/gpl-3.0.txt                ;
;================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>
#include <vault>

new Menu,Money[32];

public plugin_init(){
	register_plugin("Money Mod","1.0","Fooly Cooly");
	set_task(0.5,"showHud",0,"",0,"b");
	Menu = menu_create("Shop","menu_handle");
	register_event("DeathMsg","hook_death","a","1>0");
	register_event("StatusValue","hook_status","bd","1=2");
	register_touch("money","player","money_touch");
	register_clcmd("say /spawnshop","shop_npc",ADMIN_BAN,"")
	register_concmd("say /spawnshop","shop_npc",ADMIN_BAN,"")
}
public plugin_precache(){
	precache_model("models/money.mdl");
	precache_model("models/holo.mdl");
}
public Save(id){ 
	new authid[32],vaultkey[64],vaultdata[64];
	get_user_authid(id, authid, 31);
	format(vaultkey,63,"%s-money",authid);
	format(vaultdata,63,"%d",Money[id]);
	set_vaultdata(vaultkey,vaultdata);
}  
public Load(id){ 
	new authid[32],vaultkey[64],vaultdata[64];
	get_user_authid(id, authid, 31);
	format(vaultkey,63,"%s-money",authid);
	get_vaultdata(vaultkey,vaultdata,63);
	Money[id] = str_to_num(vaultdata);
}
public client_disconnect(id){
	Save(id);
}
public client_putinserver(id){
	Load(id);
}
public hook_death(){
	new Victim = read_data(2);
	new droped = random_num(100,300);
	if(Money[Victim]==0)
	{
		dropmoney(Victim,droped);
	}
	else if(droped>Money[Victim])
	{
		dropmoney(Victim,Money[Victim]);
		Money[Victim]=0;
		client_print(Victim,print_center,"You lost all of your money!");
	}
	else
	{
		Money[Victim]-=droped;
		client_print(Victim,print_center,"Lost $%i",droped);
		dropmoney(Victim,droped);
	}
}
public hook_status(){
}
public dropmoney(id,amount){
	new Float:origin[3];
	entity_get_vector(id,EV_VEC_origin,origin);
	new ent = create_entity("info_target");
	new Float:minbox[3] = {-2.5,-2.5,-2.5 };
	new Float:maxbox[3] = {2.5,2.5,-2.5 };
	new Float:angles[3] = {0.0,0.0,0.0 };
	angles[1] = float(random_num(0,270));
	entity_set_vector(ent,EV_VEC_mins,minbox);
	entity_set_vector(ent,EV_VEC_maxs,maxbox);
	entity_set_vector(ent,EV_VEC_angles,angles);
	entity_set_float(ent,EV_FL_dmg_take,0.0);
	entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER);
	entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS);
	entity_set_int(ent,EV_INT_iuser1,amount);
	entity_set_string(ent,EV_SZ_classname,"money");
	entity_set_model(ent,"models/money.mdl")
	entity_set_origin(ent,origin)
	return PLUGIN_HANDLED
}
public money_touch(Item,Victim){
	if(is_user_alive(Victim)){
		new Amount = entity_get_int(Item,EV_INT_iuser1);
		Money[Victim] += Amount;
		client_print(Victim,print_center,"Picked Up $%i",Amount);
		remove_entity(Item);
	}
}
public showHud(){
	new num = get_playersnum();
	for(new i = 1; i <= num; i++){
		new InfoMsg[255];
		format(InfoMsg, 254, "Id: %d	Money: $%d	Frags: %d	Deaths: %d",i,Money[i],get_user_frags(i),get_user_deaths(i));
		message_begin(MSG_ONE,get_user_msgid("StatusText"),{0, 0, 0},i);
		write_byte(0);
		write_string(InfoMsg);
		message_end();
	}
}
public shop_npc(id)
{
    new Float:origin[3]
    entity_get_vector(id,EV_VEC_origin,origin)
    new ent = create_entity("info_target")
    entity_set_origin(ent,origin);
    origin[2] += 200.0
    entity_set_origin(id,origin)
    entity_set_float(ent,EV_FL_takedamage,1.0)
    entity_set_float(ent,EV_FL_health,100.0)
    entity_set_string(ent,EV_SZ_classname,"npc_shop");
    entity_set_model(ent,"models/holo.mdl");
    entity_set_int(ent,EV_INT_solid, 2)
    entity_set_byte(ent,EV_BYTE_controller1,125);
    entity_set_byte(ent,EV_BYTE_controller2,125);
    entity_set_byte(ent,EV_BYTE_controller3,125);
    entity_set_byte(ent,EV_BYTE_controller4,125);
    new Float:maxs[3] = {16.0,16.0,36.0}
    new Float:mins[3] = {-16.0,-16.0,-36.0}
    entity_set_size(ent,mins,maxs)
    entity_set_float(ent,EV_FL_animtime,2.0)
    entity_set_float(ent,EV_FL_framerate,1.0)
    entity_set_int(ent,EV_INT_sequence,0);
    entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01)
    drop_to_floor(ent)
    return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
