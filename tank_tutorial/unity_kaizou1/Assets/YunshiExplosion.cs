using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class YunshiExplosion : MonoBehaviour {
	public GameObject explotionObject;
	// Use this for initialization
	void Start () {
		Invoke ("PlayExplotion", 3);
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void PlayExplotion()
	{
		explotionObject.SetActive (true);

	}
}
