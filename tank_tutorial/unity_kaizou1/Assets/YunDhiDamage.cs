using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class YunDhiDamage : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnTriggerEnter(Collider col)
	{
		// Collect all the colliders in a sphere from the shell's current position to a radius of the explosion radius.
		Collider[] colliders = Physics.OverlapSphere (transform.position, 3, LayerMask.GetMask("Players"));

		// Go through all the colliders...
		for (int i = 0; i < colliders.Length; i++)
		{
			// ... and find their rigidbody.
			Rigidbody targetRigidbody = colliders[i].GetComponent<Rigidbody> ();

			// If they don't have a rigidbody, go on to the next collider.
			if (!targetRigidbody)
				continue;

			// Add an explosion force.
			targetRigidbody.AddExplosionForce (300 ,transform.position, 3);

			// Find the TankHealth script associated with the rigidbody.
			Complete.TankHealth targetHealth = colliders[i].GetComponent<Complete.TankHealth> ();

			// If there is no TankHealth script attached to the gameobject, go on to the next collider.
			if (!targetHealth)
				continue;

			// Calculate the amount of damage the target should take based on it's distance from the shell.
			float damage = 25;

			// Deal this damage to the tank.
			targetHealth.TakeDamage (damage);
		}
		/*
		TankHealth tankHealth = col.gameObject.GetComponent<TankHealth> ();
		Debug.Log ("hit to :"+col.ToString());
		Debug.Log ("tankhealth?:"+tankHealth.ToString());
		if (tankHealth == null) { return; }
		Debug.Log ("hit to tankhealth!!!!!!!!!!!!!!!!!");
		tankHealth.TakeDamage (100);
		*/
	}
}
