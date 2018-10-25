using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Yunshicontroller : MonoBehaviour {
	
	float times = 2f;

	public GameObject yunshicontroller;
	//GameObject targert = null;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		times -= Time.deltaTime;
		if (times < 0) {
			GameObject obj = (GameObject)Instantiate (yunshicontroller);
			int ni = Random.Range (-25, 25);
			int nt = Random.Range (-25, 25);

			obj.transform.position = new Vector3 (ni, 0, nt);

			times = Random.Range (0, 5);
		}
	}
}
